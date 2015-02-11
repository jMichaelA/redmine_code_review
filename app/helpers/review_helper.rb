module ReviewHelper
  def committing(created, author, options={})
    l(options[:label] || "Committed by %{author} %{age} ago", :author => link_to_user(author), :age => time_tag(created)).html_safe
  end

  def render_review_changes
    changes = @changeset.filechanges.limit(1000).reorder('path').collect do |change|
      case change.action
        when 'A'
          # Detects moved/copied files
          if !change.from_path.blank?
            change.action =
                @changeset.filechanges.detect {|c| c.action == 'D' && c.path == change.from_path} ? 'R' : 'C'
          end
          change
        when 'D'
          @changeset.filechanges.detect {|c| c.from_path == change.path} ? nil : change
        else
          change
      end
    end.compact

    tree = { }
    changes.each do |change|
      p = tree
      dirs = change.path.to_s.split('/').select {|d| !d.blank?}
      path = ''
      dirs.each do |dir|
        path += '/' + dir
        p[:s] ||= {}
        p = p[:s]
        p[path] ||= {}
        p = p[path]
      end
      p[:c] = change
    end
    render_review_tree(tree[:s])
  end

  def render_review_tree(tree)
    return '' if tree.nil?
    output = ''
    output << '<ul>'
    tree.keys.sort.each do |file|
      style = 'change'
      text = File.basename(h(file))
      if s = tree[file][:s]
        style << ' folder'
        output << "<li class='#{style}'>#{text}"
        output << render_review_tree(s)
        output << "</li>"
      elsif c = tree[file][:c]
        style << " change-#{c.action}"
        path_param = to_path_param(@repository.relative_path(c.path))
        text = link_to(h(text), :controller => 'repositories',
                       :action => 'entry',
                       :id => @project,
                       :repository_id => @repository.identifier_param,
                       :path => path_param,
                       :rev => @changeset.identifier) unless c.action == 'D'
        # TODO (jchristensen) Update this when we know if a file has been approved or not
        output << "<img width='11px' src='http://localhost:3000/images/magnifier.png' style='display: inline';> <img width='11px' src='http://localhost:3000/images/true.png' style='display: inline;'>"
        output << "<li class='#{style}' style='display: inline;'>#{text}</li><br />"
      end
    end
    output << '</ul>'
    output.html_safe
  end
end
