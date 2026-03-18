local h = require("null-ls.helpers")
local methods = require("null-ls.methods")

local DIAGNOSTICS = methods.internal.DIAGNOSTICS
local parser = h.diagnostics.from_json({
  attributes = {
    row = "line",
    col = "column",
    end_row = "endLine",
    end_col = "endColumn",
    code = "code",
    severity = "level",
    message = "message",
  },
  severities = {
    error = h.diagnostics.severities.error,
    warning = h.diagnostics.severities.warning,
    info = h.diagnostics.severities.information,
    style = h.diagnostics.severities.hint,
  },
})

local parse_shellcheck_output = function(params)
  if not params.output then
    return {}
  end

  return parser({
    bufnr = params.bufnr,
    content = params.content,
    output = params.output.comments or {},
  })
end

return h.make_builtin({
  name = "shellcheck",
  meta = {
    url = "https://www.shellcheck.net/",
    description = "ShellCheck diagnostics for shell buffers. zsh files are linted in bash mode so the zsh shebang does not trip SC1071.",
  },
  method = DIAGNOSTICS,
  filetypes = { "sh", "bash", "zsh" },
  generator_opts = {
    command = "shellcheck",
    args = { "--format=json1", "--shell=bash", "$FILENAME" },
    check_exit_code = function(code)
      return code <= 1
    end,
    format = "json",
    to_stdin = false,
    to_temp_file = true,
    on_output = parse_shellcheck_output,
  },
  factory = h.generator_factory,
})
