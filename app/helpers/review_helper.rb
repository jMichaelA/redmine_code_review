module ReviewHelper
  def committing(created, author, options={})
    l(options[:label] || "Committed by %{author} %{age} ago", :author => link_to_user(author), :age => time_tag(created)).html_safe
  end
end
