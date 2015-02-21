module ReviewHelper

  def render_review_changes
    changes = @changeset.filechanges.reorder('path').collect do |change|
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

  def render_review_files
    files = @review.review_files
    files.each do |file|
      case file.change.action
        when 'A'
          # Detects moved/copied files
          if !file.change.from_path.blank?
            file.change.action =
                @changeset.filechanges.detect {|c| c.action == 'D' && c.path == file.change.from_path} ? 'R' : 'C'
          end
          change
        when 'D'
          @changeset.filechanges.detect {|c| c.from_path == file.change.path} ? nil : file.change
        else
          file.change
      end
    end.compact

    tree = { }
    files.each do |file|
      p = tree
      dirs = file.change.path.to_s.split('/').select {|d| !d.blank?}
      path = ''
      dirs.each do |dir|
        path += '/' + dir
        p[:s] ||= {}
        p = p[:s]
        p[path] ||= {}
        p = p[path]
      end
      p[:c] = file.change
      p[:f] = file
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
        id_param = tree[file][:f].id
        text = link_to(h(text), :controller => 'reviews',
                       :action => 'show',
                       :id => @project,
                       :repository_id => @repository.identifier_param,
                       :file_id => id_param) if c.action == 'M'
        # TODO (jchristensen) Update this when we know if a file has been approved or not
        output << "<li class='#{style}' style='background-position: 5px;  display: block;'>#{text}  <img width='11px' src='http://localhost:3000/images/magnifier.png';> <img width='11px' src='http://localhost:3000/images/true.png'> <img width='11px' src='http://localhost:3000/images/false.png'></li>  "
      end
    end
    output << '</ul>'
    output.html_safe
  end

  def link_to_review(review)
    link_to(review.id, {:controller => 'reviews', :action => 'show', :id => review.project, :review_id => review.id})
  end
end
