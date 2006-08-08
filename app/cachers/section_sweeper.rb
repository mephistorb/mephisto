class SectionSweeper < ArticleSweeper
  observe Section

  undef :after_create
end