local fmt = string.format

return {
  "olimorris/codecompanion.nvim",
  event = "VeryLazy",
  opts = {
    display = {
      action_palette = {
        width = 80,
        height = 10,
        prompt = "Prompt ",                   -- Prompt used for interactive LLM calls
        provider = "default",                 -- Can be "default", "telescope", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
        opts = {
          show_default_actions = true,        -- Show the default actions in the action palette?
          show_default_prompt_library = true, -- Show the default prompt library in the action palette?
        },
      },
      diff = {
        enabled = false
      },
      chat = {
        start_in_insert_mode = false,
        show_settings = false,
        window = {
          layout = "vertical", -- float|vertical|horizontal|buffer
          position = nil,      -- left|right|top|bottom (nil will default depending on vim.opt.splitright|vim.opt.splitbelow)
          border = "solid",
          height = 0.8,
          width = 0.35,
          relative = "editor",
          full_height = true,
          opts = {
            breakindent = false,
            cursorcolumn = false,
            cursorline = false,
            foldcolumn = "0",
            linebreak = true,
            list = false,
            numberwidth = 1,
            signcolumn = "no",
            spell = false,
            wrap = true,
            -- Custom
            scrolloff = 3, -- Lines of context
            relativenumber = false,
            number = false,
            fillchars = "eob: ,vert:│",
          },
        },
      },
    },
    adapters = {
      claude = function()
        return require("codecompanion.adapters").extend("anthropic", {
          name = "Cate (claude)",
          schema = {
            model = {
              -- default = "claude-3-7-sonnet-20250219",
              default = "claude-3-5-sonnet-20241022",
            },
          },
          env = {
            api_key = "cmd:op read op://ix4sh7cjltmluk6jv3gpffeptm/b4hiqit2dh352cx4bc54t3djb4/credential --no-newline",
          },
        })
      end,
      openai = function()
        return require("codecompanion.adapters").extend("openai", {
          name = "Oliver (openai)",
          schema = {
            model = {
              default = "gpt-4o-mini",
            },
          },
          env = {
            api_key = "cmd:op read op://ix4sh7cjltmluk6jv3gpffeptm/rpxqvymji6d7bbchlfi4ltilgy/credential --no-newline",
          },
        })
      end,
    },
    strategies = {
      chat = {
        adapter = "claude",
      },
      inline = {
        adapter = "claude",
      },
      cmd = {
        adapter = "claude",
      }
    },
    prompt_library = {
      ["Rename code block"] = {
        strategy = "inline",
        description = "An aspirational renaming approach",
        opts = {
          -- mapping = "<LocalLeader>ce",
          -- modes = { "v" },
          short_name = "rename",
          -- is_slash_cmd = true,
          auto_submit = true,
          stop_context_insertion = true,
          user_prompt = false,
          placement = "replace",
          pre_hook = function()
            vim.api.nvim_command("normal! ^v$")
            return vim.api.nvim_get_current_buf()
          end
        },
        prompts = {
          {
            role = "system",
            content = function(context)
              -- vim.api.nvim_command("normal! ^v$")
              return fmt(
                "You are a vibrant but prudent senior %s developer. Inspired by the 'clean code' handbook, but not beholden to it. You favour clarity and communication over cleverness.",
                context.filetype)
            end,
          },
          {
            role = "user",
            content = function(context)
              local buf_utils = require("codecompanion.utils.buffers")
              local content_ok, content = pcall(buf_utils.get_content, context.bufnr)
              if not content_ok then
                error("Could not provide buffer")
                return
              end

              local line_ok, line = pcall(buf_utils.get_line, context.bufnr, context.start_line)
              if not line_ok then
                error("Could not provide line " .. context.start_line)
                return
              end

              local entity = "function"
              if context.filteyp == "ruby" then
                entity = "method"
              end

              return string.format(
                [[I want you to rename a %s with a more successful alternative. Consider and evlauate alternatives %s names for the below on line %d:

```%s
%s
```

The entire buffer is provided below for a broader understanding of the surrounding context:

```%s
%s
```

<user_prompt>
Replace the CURRENT EXACT NAME with the best alternative at the PRECISE location taking INDENTATION and FORMATTING into account
</user_prompt>]],
                entity, entity,
                context.start_line,
                context.filetype, line,
                context.filetype, content
              )
            end,
            opts = {
              contains_code = true,
              auto_submit = true,
              visible = false,
            }
          },
        },
      }
    },
    opts = {
      log_level = "DEBUG", -- TRACE|DEBUG|ERROR|INFO see ~/.local/state/nvim/codecompanion.log
      system_prompt = function(opts)
        return
        [[You are a vibrant software engineer named 'Jeff'. You are currently plugged in to the Neovim text editor on my machine.

  Your core tasks include:
  - Answering general programming questions.
  - Explaining how the code in a Neovim buffer works.
  - Reviewing the selected code in a Neovim buffer.
  - Generating unit tests for the selected code.
  - Proposing fixes for problems in the selected code.
  - Scaffolding code for a new workspace.
  - Finding relevant code to the user's query.
  - Proposing fixes for test failures.
  - Answering questions about Neovim.
  - Running tools.

  You must:
  - Follow the user's requirements carefully and to the letter.
  - Keep your answers short and impersonal, especially if the user responds with context outside of your tasks.
  - Minimize other prose.
  - Use Markdown formatting in your answers.
  - Include the programming language name at the start of the Markdown code blocks.
  - Avoid including line numbers in code blocks.
  - Avoid wrapping the whole response in triple backticks.
  - Only return code that's relevant to the task at hand. You may not need to return all of the code that the user has shared.
  - Favour a functional and terse programming style
  - Use actual line breaks instead of '\n' in your response to begin new lines.
  - Use '\n' only when you want a literal backslash followed by a character 'n'.
  - All non-code responses must be in english.

  When given a task:
  1. Think step-by-step and describe your plan for what to build in pseudocode, written out in great detail, unless asked not to do so.
  2. Output the code in a single code block, being careful to only return relevant code.
  3. When appropriate generate short suggestions for the next user turns that are relevant to the conversation.
  4. You can only give one reply for each conversation turn.
]]
      end,
    }
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      -- opts = {
      --   file_types = { "markdown", "codecompanion" },
      -- },
      ft = { "markdown", "codecompanion" },
    },
  },
  config = function(_, opts)
    CodeCompanion = require("codecompanion")
    CodeCompanion.setup(opts)

    local function is_codecompanion_open()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].filetype == 'codecompanion' then
          return true
        end
      end
      return false
    end

    local function toggle_code_companion()
      if is_codecompanion_open() then
        vim.cmd('CodeCompanionChat Toggle')

        -- local context = require("codecompanion.utils.context").get(api.nvim_get_current_buf())
        -- local content = table.concat(context.lines, "\n")

        -- local chat = CodeCompanion.last_chat()
        -- if not chat then
        --   chat = CodeCompanion.chat()

        --   if not chat then
        --     return log:warn("Could not create chat buffer")
        --   end
        -- end

        -- chat:add_buf_message({
        --   role = config.constants.USER_ROLE,
        --   content = "Here is some code from "
        --       .. context.filename
        --       .. ":\n\n```"
        --       .. context.filetype
        --       .. "\n"
        --       .. content
        --       .. "\n```\n",
        -- })
        -- -- chat.ui:open()
      else
        vim.cmd('CodeCompanionChat')
      end
    end

    vim.keymap.set({ 'n', 'v' }, '<leader>ac', toggle_code_companion, { desc = 'Execute custom action' })

    vim.keymap.set({ "n", "v" }, "<Leader>aa", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    -- vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd [[cab cc CodeCompanion]]

    -- Style highlights
    require("highlights").register(function()
      local colours = require("colours")
      colours.hi("CodeCompanionChatVariable", { fg = 6, bg = 0 })
    end)
  end
}
