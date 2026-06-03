local map = vim.keymap.set

-- general mappings
map("n", "<C-s>", "<cmd> w <CR>")
map("i", "jk", "<ESC>")
map("n", "<C-c>", "<cmd> %y+ <CR>") -- copy whole filecontent

-- nvimtree
map("n", "<C-n>", "<cmd> NvimTreeToggle <CR>")
map("n", "<leader>e", "<cmd> NvimTreeToggle <CR>", { desc = "Explorer"})
map("n", "<C-h>", "<cmd> NvimTreeFocus <CR>")
map("n", "<leader>E", "<cmd> NvimTreeFocus <CR>", { desc = "Explorer Focus"})


-- telescope
map("n", "<leader>ff", "<cmd> Telescope find_files <CR>")
map("n", "<leader>fo", "<cmd> Telescope oldfiles <CR>")
map("n", "<leader>fw", "<cmd> Telescope live_grep <CR>")
map("n", "<leader>gt", "<cmd> Telescope git_status <CR>")

-- bufferline, cycle buffers
map("n", "<Tab>", "<cmd> BufferLineCycleNext <CR>")
map("n", "<S-Tab>", "<cmd> BufferLineCyclePrev <CR>")
map("n", "<C-q>", "<cmd> bd <CR>")

-- comment.nvimmap("n", "<leader>q", { "<cmd>qwa<CR>", desc = ":qwa" })
map("n", "<leader>/", "gcc", { remap = true })
map("v", "<leader>/", "gc", { remap = true })

-- Fechar / Salvar
map("n", "<leader>q", "<cmd>wqa<CR>", { desc = ":wqa" })
map("n", "<C-q>", "<cmd>wqa<CR>", { desc = ":wqa" })
map("n", "<leader>Q", "<cmd>q!<CR>", { desc = ":q!" })

-- format
map("n", "<leader>fm", function()
  require("conform").format()
end)
