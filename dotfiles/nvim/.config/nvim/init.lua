-- ==========================================
-- 1. 基本設定 (Basic Settings)
-- ==========================================
vim.opt.shortmess:append("I")

-- リーダーキーをスペースに設定 (これが起点となります)
vim.g.mapleader = " "

-- 行番号を表示
vim.opt.number = true
-- 相対行番号を表示（カーソル移動の距離がわかりやすくなります）
-- 慣れていない場合は false にしてもOKです
vim.opt.relativenumber = true 

-- インデント設定 (C/Verilog向けに4スペース)
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true -- タブをスペースに変換
vim.opt.smartindent = true

-- クリップボードをOSと共有 (Ctrl+C / Ctrl+V的な挙動のため)
vim.opt.clipboard = "unnamedplus"

-- 検索設定
vim.opt.ignorecase = true -- 大文字小文字を区別しない
vim.opt.smartcase = true  -- 大文字が含まれる場合のみ区別する

-- マウス操作を有効化
vim.opt.mouse = "a"

-- エンコーディング
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

-- バッファ切替
vim.keymap.set('n', '<C-j>', ':bprev<CR>', { silent = true })
vim.keymap.set('n', '<C-k>', ':bnext<CR>', { silent = true })
vim.keymap.set('n', '<leader>bd', '<cmd>bp|bd #<CR>', { desc = '現在バッファを即閉じる（注意）' })

-- Terminal Escape設定
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { silent = true })

-- 1. 絵文字を使用しない (絵文字を全角幅として扱わない設定)
-- ※表示自体を禁止するものではありませんが、エディタ上の文字幅計算における「絵文字モード」を無効化します。
vim.opt.emoji = false

-- 2. 相対行表示を無効化する
vim.opt.relativenumber = false
vim.opt.number = true -- 代わりに通常の絶対行番号を表示する（必要であれば）

-- 3. 現在位置の行をハイライト表示する
vim.opt.cursorline = true

-- 選択単語を検索

-- Visual * : 選択範囲をリテラル( \V )として検索
vim.keymap.set('x', '*', function()
  -- 選択範囲をレジスタ v にヤンク
  vim.cmd([[normal! "vy]])
  -- 取り出し
  local text = vim.fn.getreg('v')
  --   escape(@v,'\/')  ->  / と \ をエスケープ
  --   substitute(...,"\n",'\\n','g') -> 改行を \n に変換
  local pat = vim.fn.escape(text, [[\/]])
  pat = vim.fn.substitute(pat, "\n", [[\\n]], "g")
  -- very nomagic で検索（完全一致検索）
  local search_pat = [[\V]] .. pat
  -- 検索レジスタに入れて、ハイライトも効くようにする
  vim.fn.setreg('/', search_pat)
  -- 次の一致へ移動（必要なら 'W' で末尾まで行ったら止まる、'w' でラップ）
  vim.fn.search(search_pat, 'w')
end, { silent = true, desc = "Search selected text literally" })


-- lsp
-- Verilog/SystemVerilog (verible) の設定
-- verible-ls は Verible 言語サーバーの実行ファイル名です
vim.lsp.config('verible-verilog-ls', {
  cmd = { 'verible-verilog-ls' },
  -- Filetypes to automatically attach to.
  filetypes = { 'verilog', 'systemverilog' },
  settings = {
    ['verible-verilog-ls']  = {
      -- ここに lint のパスや、特定のルールのオンオフを記述できます
      -- 例: analysis_args = {"--ruleset", "all"}
    },
  },
})
vim.lsp.enable('verible-verilog-ls')

-- C/C++ (clangd) の設定
vim.lsp.config('clangd', {
  -- 実行ファイル名。パスが通っていればこれでOKです
  cmd = { 'clangd' },
  -- C, C++, Objective-C などを対象にします
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto' },
  settings = {
    ['clangd'] = {
      -- ここに特定の引数や設定を追加できます
    },
  },
})

-- 設定を有効化
vim.lsp.enable('clangd')

-- ==========================================
-- 4. カスタムコマンド (Pandoc & Browser)
-- ==========================================

local function md_to_html_and_open()
    -- 未保存だと変換が古いので保存
    pcall(vim.cmd, "write")


    local filepath = vim.fn.expand('%:p')
    if filepath == nil or filepath == "" then
        print("Error: buffer has no file path (save the file first).")
        return
    end

    local filename_no_ext = vim.fn.expand('%:p:r')
    local output_file = filename_no_ext .. ".html"

    -- CSSファイルのフルパス
    local css_path = vim.fn.expand('~/.config/nvim/utils/ik.css')

    -- 画像など相対パス用: md のあるディレクトリ

    local resource_dir = vim.fn.expand('%:p:h')

    -- shellescape で安全にクォート（最小修正で堅牢化）
    local se = vim.fn.shellescape

    -- Pandocコマンド
    local pandoc_cmd = string.format(
        "pandoc -s %s -o %s -c %s --metadata title=%s --resource-path=%s",
        se(filepath),
        se(output_file),
        se(css_path),
        se("Preview"),
        se(resource_dir)
    )

    vim.fn.system(pandoc_cmd)


    if vim.v.shell_error == 0 then
        -- 初回だけブラウザで開く（以後は変換のみ）
        if not vim.b.pdhtml_opened then
            local win_path = vim.fn.system(string.format("wslpath -w %s", se(output_file))):gsub("\n", "")
            -- 既定ブラウザで開く（& は不要）
            vim.fn.system(string.format("explorer.exe %s", se(win_path)))

            vim.b.pdhtml_opened = true
            print("Done: GitHub-style HTML opened (first time)")
        else
            print("Done: HTML updated (browser already opened)")
        end
    else
        print("Error: Pandoc conversion failed.")
    end
end

-- コマンド :Pdhtml を登録
vim.api.nvim_create_user_command('Pdhtml', md_to_html_and_open, {})


-- ==========================================
-- 2. プラグインマネージャ (lazy.nvim) のセットアップ
-- ==========================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ==========================================
-- 3. プラグインの定義と設定
-- ==========================================
require("lazy").setup({
    --Parser: TreeSitter
--    {
--        'nvim-treesitter/nvim-treesitter',
--        lazy = false,
--        build = ':TSUpdate',
--	config = function()
--	    require'nvim-treesitter'.install { 'cpp', 'verilog', 'lua' , 'vim', 'vimdoc', 'query', 'markdown' }
--	end
--    },
    -- カラースキーム: Gruvbox
    { 
        "ellisonleao/gruvbox.nvim", 
        priority = 1000, 
        config = function()
            vim.o.background = "dark" -- "light" に変更可能
            vim.cmd([[colorscheme gruvbox]])
        end,
    },

    -- ステータスライン: Lualine
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }, -- アイコン表示用
        config = function()
            require('lualine').setup({
                options = { 
                    theme = 'gruvbox',
                    icons_enabled = false, -- アイコン無効化
                    component_separators = '|',
                    section_separators = '',
                },
                
                sections = {
                  lualine_a = { 'mode' },
                  lualine_b = { 'branch' },
                  lualine_c = { { 'filename', path = 3 } },
                },

                tabline = {
                    -- 左上: 開いているバッファ(ファイル)一覧を表示
                    lualine_a = {{
                        'buffers',
                        mode = 2, -- 0: バッファ名のみ, 1: バッファ番号+名, 2: 番号+名(詳細), 4: 番号+名(詳細)+トグル
                    }},
                    -- 右上: タブ番号を表示
                    lualine_z = {'tabs'}
                }
            })
        end
    },

    -- ファイラ: Fern
    {
        'lambdalisue/fern.vim',
        dependencies = {
            'lambdalisue/fern-hijack.vim',            -- 1. nvim {dir} でFernを起動させる
            'lambdalisue/nerdfont.vim',               -- 2. アイコン用フォント

            'lambdalisue/fern-renderer-nerdfont.vim', -- 2. Fernでアイコンを表示するレンダラー
            'lambdalisue/glyph-palette.vim',          -- 2. アイコンに色をつける (VSCodeライクにするため推奨)
        },
        config = function()

            vim.keymap.set('n', '<C-n>', ':Fern . -drawer -toggle<CR>', { silent = true })

            -- 隠しファイルを表示
            vim.g['fern#default_hidden'] = 1

            -- -----------------------------------------
            -- VSCodeライクな見た目 & 補助線
            -- -----------------------------------------
            -- アイコンを表示するためのレンダラー設定
            vim.g['fern#renderer'] = 'nerdfont'

            -- 3. ディレクトリの階層に補助線（ガイドライン）を引く
            vim.g['fern#renderer#nerdfont#indent_markers'] = 1

            -- アイコンに色をつける自動コマンド (glyph-palette)
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "fern",
                callback = function()
                    vim.fn['glyph_palette#apply']()
                
                    -- 2. キーマップ変更: Enterを 'l' (open:or-expand) と同じにする
                    -- local opts = { buffer = true, silent = true, remap = true }
                    -- vim.keymap.set('n', '<CR>', '<Plug>(fern-action-open:or-expand)', opts)
                    vim.keymap.set('n', '<CR>', 'l', { buffer = true, remap = true })
                end,

            })
        
            -- local fern_group = vim.api.nvim_create_augroup('FernStartup', { clear = true })
            local fern_group = vim.api.nvim_create_augroup('FernMyConf', { clear = true })

            vim.api.nvim_create_autocmd('BufRead', {
              group = 'FernMyConf',
              nested = true, --　必須
              callback = function()
                if vim.bo.filetype ~= "fern" and vim.bo.buftype == "" then
                  vim.cmd [[Fern . -reveal=% -drawer -stay]]
                end
              end
            })
            -- 1) 起動時に Fern を開く（フォーカスを奪いたくなければ -stay）
            -- vim.api.nvim_create_autocmd('VimEnter', {
            --   group = fern_group,
            --   nested = true,
            --   callback = function()
            --     -- 必ず表示したいなら -toggle は付けない方が安定します
            -- 
            --     -- -reveal=% は「現在バッファの位置を展開してフォーカス」[4](https://github.com/lambdalisue/vim-fern)
            --     vim.cmd([[Fern . -drawer -reveal=% -stay]])
            --   end,
            -- })
            
            -- 2) Fern バッファが開いたら自動で「enter」してディレクトリ一覧を表示
            -- vim.api.nvim_create_autocmd('FileType', {
            --   group = fern_group,
            --   pattern = 'fern',
            --   callback = function()
            --     -- ルート（.）からディレクトリに「入る」= enter アクション[1](https://github-wiki-see.page/m/lambdalisue/vim-fern/wiki/Tips)[2](https://zenn.dev/masaino/articles/1051a7c0ae8a8c)
            --     vim.api.nvim_feedkeys(
            --       vim.api.nvim_replace_termcodes("<Plug>(fern-action-enter)", true, false, true),
            --       "n",
            -- 
            --       false
            --     )
            --   end,
            -- })
        end
    },
    {
      "ibhagwan/fzf-lua",
    keys = {
        -- 追加リクエスト分
        { "<leader>ff", function() require("fzf-lua").files() end,     desc = "Find Files" },
        { "<leader>fg", function() require("fzf-lua").live_grep() end, desc = "Find Grep (Live)" },

        -- 参照/定義/実装/型

        { "gr", function() require("fzf-lua").lsp_references() end,         desc = "LSP References" },
        { "gd", function() require("fzf-lua").lsp_definitions() end,        desc = "Go to Definition" },
        { "gD", function() require("fzf-lua").lsp_declarations() end,       desc = "Go to Declaration" },
        { "gi", function() require("fzf-lua").lsp_implementations() end,    desc = "Go to Implementations" },
        { "gy", function() require("fzf-lua").lsp_typedefs() end,           desc = "Type Definition" },


        -- シンボル（ファイル / ワークスペース）

        { "<leader>ss", function() require("fzf-lua").lsp_document_symbols() end,  desc = "Doc Symbols" },

        { "<leader>sS", function() require("fzf-lua").lsp_workspace_symbols() end, desc = "Workspace Symbols" },

        -- 診断（エラー/警告）

        { "<leader>xx", function() require("fzf-lua").diagnostics_document() end,  desc = "Diagnostics (Doc)" },
        { "<leader>xX", function() require("fzf-lua").diagnostics_workspace() end, desc = "Diagnostics (WS)" },

        -- 補助: カーソル語を ripgrep

        { "gR", function() require("fzf-lua").grep_cword() end,             desc = "Grep word under cursor" },
      },
      opts = function()
        return {

          -- プロンプトのアイコンや見た目を微調整（任意）
          fzf_opts = { ["--tiebreak"] = "begin" },

          winopts = {

            height = 0.90,
            width = 0.90,
            preview = { layout = "horizontal", vertical   = 'right:65%' },
          },
          lsp = {
            -- 候補が1件なら即ジャンプ
            jump1 = true,
            -- シンボルの表示スタイル
            symbols = { symbol_style = 1 },
          },
        }
      end,
      config = function(_, opts)
        require("fzf-lua").setup(opts)
      end,
    },
    -- 自動補完・LSP: CoC.nvim
    -- {
    --     'neoclide/coc.nvim',
    --     branch = 'release',
    --     config = function()
    --         -- CoC用のキーマッピング設定 (重要)
    --         
    --         -- Enterキーで補完を確定
    --         vim.keymap.set("i", "<CR>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], { expr = true, silent = true })

    --         -- 定義ジャンプ (gd)
    --         vim.keymap.set("n", "gd", "<Plug>(coc-definition)", {silent = true})
    --         -- 型定義ジャンプ (gy)
    --         vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", {silent = true})
    --         -- 実装ジャンプ (gi)
    --         vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", {silent = true})
    --         -- 参照一覧 (gr)
    --         vim.keymap.set("n", "gr", "<Plug>(coc-references)", {silent = true})
    --         
    --         -- 変数名の一括変更 (<leader>rn)
    --         vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)", {silent = true})
    --         
    --         -- カーソル位置のドキュメント表示 (K)
    --         function _G.show_docs()
    --             local cw = vim.fn.expand('<cword>')
    --             if vim.fn.index({'vim', 'help'}, vim.bo.filetype) >= 0 then
    --                 vim.api.nvim_command('h ' .. cw)
    --             elseif vim.api.nvim_eval('coc#rpc#ready()') then
    --                 vim.fn.CocActionAsync('doHover')
    --             else
    --                 vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    --             end
    --         end
    --         vim.keymap.set("n", "K", '<CMD>lua _G.show_docs()<CR>', {silent = true})
    --     end
    -- },
    {
      "sindrets/diffview.nvim",
      config = function ()
        require("diffview").setup()
      end,
      lazy = false,
      keys = {
        {mode = "n", "<leader>hh", "<cmd>DiffviewOpen HEAD~1<CR>", desc = "1つ前とのdiff"},
        {mode = "n", "<leader>hf", "<cmd>DiffviewFileHistory %<CR>", desc = "ファイルの変更履歴"},
        {mode = "n", "<leader>hc", "<cmd>DiffviewClose<CR>", desc = "diffの画面閉じる"},
        {mode = "n", "<leader>hd", "<cmd>Diffview<CR>", desc = "コンフリクト解消画面表示"},
      },
    },
    {
        'akinsho/toggleterm.nvim',
        version = "*",
        config = function()
            require("toggleterm").setup({
                -- 1. Ctrl + \ で開閉する設定
                open_mapping = [[<C-\>]],

                -- 2. 見た目の設定
                -- 'horizontal': VSCodeのように下に分割して表示
                -- 'float': 真ん中に浮かせて表示
                direction = 'horizontal', 
                
                -- 下に表示するときの高さ
                size = 15,

                -- シェルを枠線で囲むかどうか (floatの時などに有効)
                shade_terminals = true,
            })

            -- 3. ターミナル操作の便利設定
            -- ターミナルが開いたときだけ有効になるキーマップを定義
            function _G.set_terminal_keymaps()
              local opts = {buffer = 0}
              -- Esc キーでターミナルモード(入力)から抜ける (これが無いとCtrl+\+nが必要で大変です)
              vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], opts)
              -- jk でウィンドウ移動もできるようにする (お好みで)
              vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
              vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
              vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
              vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
            end

            -- 上記のキー設定を適用
            vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')
        end
    }
})
