local ret_func = {}


local function escape_pattern(string_val)
    return string_val:gsub("([^%w])", "%%%1")
end


function ret_func.show_current_scope()
    local screen_percentage = 0.70
    local width = math.floor(vim.o.columns * screen_percentage)
    local height = 15
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor(((vim.o.lines - height) / 2) - 1)

    local user_current_window = vim.fn.win_getid()
    local current_buffer_filename = vim.api.nvim_buf_get_name(0)
    local current_working_dir = vim.fn.getcwd()
    local current_git_remote_url = vim.fn.system('git config --get remote.origin.url')
    local current_git_branch = vim.fn.system('git rev-parse --abbrev-ref HEAD')

    if current_git_remote_url == "" then
        current_git_remote_url = ""
    else
        current_git_remote_url = current_git_remote_url:gsub("%s+$", "")
    end

    if current_git_branch == "" then
        current_git_branch = ""
    else
        current_git_branch = current_git_branch:gsub("%s+$", "")
    end

    -- Normalize path seperation between OS
    current_buffer_filename = current_buffer_filename:gsub("\\", "/")
    current_working_dir = current_working_dir:gsub("\\", "/")

    local escaped_current_working_dir = escape_pattern(current_working_dir)
    local relative_file_path = current_buffer_filename:gsub("^" .. escaped_current_working_dir .. "/", "")

    local window_buffer = vim.api.nvim_create_buf(false,true)
    local is_enter_window = true

    local win_opt = {
        title = 'Current Workspace Info',
        relative = "editor",
        focusable = true,
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = 'single',
    }

    local disp_buf = {'===== Relative File Path =====', relative_file_path, '', '===== Current CWD =====', current_working_dir, '', '===== Full file Path =====', current_buffer_filename, '', '===== Current Git remote Url =====', current_git_remote_url, '', '===== Current git branch =====', current_git_branch}

    vim.api.nvim_buf_set_lines(window_buffer,0,-1,false,disp_buf)
    winnr = vim.api.nvim_open_win(
        window_buffer,
        is_enter_window,
        win_opt
    )

    -- Define highlight color for each information
    vim.api.nvim_set_hl(0, "custom_current_workspace_info_highlight_relative_file_path", {fg = "#f45eff"})
    vim.api.nvim_set_hl(0, "custom_current_workspace_info_highlight_cwd", {fg = "#ff4f95"})
    vim.api.nvim_set_hl(0, "custom_current_workspace_info_highlight_full_file_path", {fg = "#3399FF"})
    vim.api.nvim_set_hl(0, "custom_current_workspace_info_highlight_git_remote_origin_url", {fg = "#99FF33"})
    vim.api.nvim_set_hl(0, "custom_current_workspace_info_highlight_git_branch", {fg = "#f59842"})

    -- Add highlight color for each information
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_relative_file_path", 1, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_cwd", 4, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_full_file_path", 7, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_git_remote_origin_url", 10, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_git_branch",13, 0, -1)

    -- Define highlight color for infomration title
    vim.api.nvim_set_hl(0, "custom_current_workspace_info_highlight_info_title", {fg = "#c4c4c4"})

    -- Add highlight color for infomration title
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_info_title",0, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_info_title",3, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_info_title",6, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_info_title",9, 0, -1)
    vim.api.nvim_buf_add_highlight(window_buffer, 0, "custom_current_workspace_info_highlight_info_title",12, 0, -1)

    local close_cmd_window = '<Cmd>lua vim.api.nvim_set_current_win(' .. user_current_window .. '); <CR>'
    vim.api.nvim_buf_set_keymap(window_buffer,'n','<Esc>',close_cmd_window, {noremap=true, silent=true})
    local au_workspace_info_id = vim.api.nvim_create_augroup("au_workspace_info", {clear = true})
    local autocmd_buf_enter_buf = vim.api.nvim_create_autocmd(
        "BufEnter",
        {
            group = au_workspace_info_id,
            callback = function ()
                local curr_win_id = vim.fn.win_getid()
                if winnr == curr_win_id then
                    -- do nothing
                else
                    vim.api.nvim_clear_autocmds(
                        {
                            group = au_workspace_info_id,
                        }
                    )
                end
                vim.api.nvim_win_close(winnr, true)
            end
        }
    )
end


return ret_func
