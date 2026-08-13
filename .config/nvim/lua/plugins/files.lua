return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          -- Настройка для окна explorer (space e)
          explorer = {
            hidden = true, -- Показываем скрытые файлы (.env, .gitignore)
            ignored = true, -- Показываем файлы из .gitignore (опционально)
          },
          -- Настройка для поиска файлов (space space)
          files = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
