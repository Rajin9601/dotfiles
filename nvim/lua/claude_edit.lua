-- One-shot, non-interactive "edit this selection" using `claude -p`.
-- Does not depend on claudecode.nvim or any running Claude terminal/session.
local M = {}

local ns = vim.api.nvim_create_namespace "claude_edit_diff"

local function build_prompt(instruction, filetype, code)
  return table.concat({
    "You are a precise code transformation tool. Apply the user's instruction to the given code selection.",
    "",
    "Rules:",
    "- Output ONLY the transformed code, nothing else.",
    "- Do NOT include markdown code fences (no ```).",
    "- Do NOT include explanations, comments about what you changed, or any surrounding prose.",
    "- Preserve the original indentation style unless the instruction requires otherwise.",
    "- Output the FULL replacement for the entire code selection, not just the changed lines.",
    "",
    "Instruction: " .. instruction,
    "",
    "Code selection (language: " .. (filetype ~= "" and filetype or "text") .. "):",
    code,
  }, "\n")
end

-- Defensive: strip a fence if the model added one despite instructions.
local function strip_fences(text)
  text = text:gsub("^```[%w_-]*\n", ""):gsub("\n```%s*$", "")
  text = text:gsub("\n$", "")
  return text
end

local function show_diff_preview(bufnr, start_line, end_line, old_lines, new_lines, on_accept)
  local old_text = table.concat(old_lines, "\n") .. "\n"
  local new_text = table.concat(new_lines, "\n") .. "\n"
  local hunks = vim.diff(old_text, new_text, { result_type = "indices", algorithm = "histogram" })

  local render_lines = {}
  local highlights = {}

  if not hunks or #hunks == 0 then
    render_lines = { "(no textual difference)" }
  else
    for _, hunk in ipairs(hunks) do
      local old_start, old_count, new_start, new_count = hunk[1], hunk[2], hunk[3], hunk[4]
      for i = 0, old_count - 1 do
        local line = old_lines[old_start + i]
        if line then
          table.insert(render_lines, "- " .. line)
          highlights[#render_lines] = "DiffDelete"
        end
      end
      for i = 0, new_count - 1 do
        local line = new_lines[new_start + i]
        if line then
          table.insert(render_lines, "+ " .. line)
          highlights[#render_lines] = "DiffAdd"
        end
      end
    end
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, render_lines)
  vim.bo[buf].filetype = vim.bo[bufnr].filetype
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  for lnum, hl in pairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns, hl, lnum - 1, 0, -1)
  end

  local width = math.min(math.max(40, math.floor(vim.o.columns * 0.6)), 120)
  local height = math.min(#render_lines + 2, math.floor(vim.o.lines * 0.6))

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 0,
    width = width,
    height = math.max(height, 3),
    style = "minimal",
    border = "rounded",
    title = " Claude edit — [a]ccept  [q/Esc] reject ",
    title_pos = "center",
  })
  vim.wo[win].wrap = false

  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end

  local function accept()
    close()
    on_accept()
  end

  vim.keymap.set("n", "a", accept, { buffer = buf, nowait = true, desc = "Accept Claude edit" })
  vim.keymap.set("n", "q", close, { buffer = buf, nowait = true, desc = "Reject Claude edit" })
  vim.keymap.set("n", "<Esc>", close, { buffer = buf, nowait = true, desc = "Reject Claude edit" })
end

function M.edit_selection()
  local bufnr = vim.api.nvim_get_current_buf()
  local start_line = vim.fn.line "'<"
  local end_line = vim.fn.line "'>"
  if start_line == 0 or end_line == 0 then
    vim.notify("claude_edit: no visual selection found", vim.log.levels.WARN)
    return
  end

  local old_lines = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, end_line, false)
  if #old_lines == 0 then
    vim.notify("claude_edit: empty selection", vim.log.levels.WARN)
    return
  end
  local filetype = vim.bo[bufnr].filetype

  vim.ui.input({ prompt = "Claude edit instruction: " }, function(instruction)
    if not instruction or instruction:match "^%s*$" then return end

    local prompt = build_prompt(instruction, filetype, table.concat(old_lines, "\n"))
    vim.notify("Claude: thinking...", vim.log.levels.INFO)

    vim.system(
      { "claude", "-p", "--output-format", "json", "--tools", "" },
      { stdin = prompt, text = true },
      function(obj)
        vim.schedule(function()
          if obj.code ~= 0 then
            vim.notify(
              "claude_edit: claude exited with code " .. obj.code .. "\n" .. (obj.stderr or ""),
              vim.log.levels.ERROR
            )
            return
          end

          local ok, decoded = pcall(vim.json.decode, obj.stdout)
          if not ok or not decoded then
            vim.notify("claude_edit: failed to parse claude output", vim.log.levels.ERROR)
            return
          end

          if decoded.is_error then
            vim.notify("claude_edit: " .. (decoded.result or "unknown error"), vim.log.levels.ERROR)
            return
          end

          local new_text = strip_fences(decoded.result or "")
          local new_lines = vim.split(new_text, "\n", { plain = true })

          if not vim.api.nvim_buf_is_valid(bufnr) then return end

          show_diff_preview(bufnr, start_line, end_line, old_lines, new_lines, function()
            if vim.api.nvim_buf_is_valid(bufnr) then
              vim.api.nvim_buf_set_lines(bufnr, start_line - 1, end_line, false, new_lines)
            end
          end)
        end)
      end
    )
  end)
end

return M
