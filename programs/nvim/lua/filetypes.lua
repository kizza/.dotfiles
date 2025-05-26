-- Add prawn
vim.filetype.add({
  extension = {
    prawn = 'prawn',
  }
})
vim.treesitter.language.register('ruby', 'prawn')
