class ArticleSweeper < CacheReferences::Sweeper
  observe Article

  def before_save(record)
    if record.new_record? or record.just_published?
      expire_cached_pages_by_site(record.section.site)
    else
      expire_cached_pages_by_reference(record)
    end
  end

  alias after_destroy before_save
end
