local ret_func = {}


function ret_func.show_current_scope()
    local screen_percentage = 0.70
    local width = math.floor(vim.o.columns * screen_percentage)
    local height = 4
    local col = math.floor((vim.o.columns - width) / 2)
    local row = math.floor(((vim.o.lines - height) / 2) - 1)

    local user_current_window = vim.fn.win_getid()
    local current_buffer_filename = vim.api.nvim_buf_get_name(0)
    local current_working_dir = vim.fn.getcwd()
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

    local disp_buf = {'===== Current Filepath =====', current_buffer_filename, '===== Current CWD =====', current_working_dir}

    vim.api.nvim_buf_set_lines(window_buffer,0,-1,false,disp_buf)
    winnr = vim.api.nvim_open_win(
        window_buffer,
        is_enter_window,
        win_opt
    )

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
