#-- copyright
# OpenProject Backlogs Plugin
#
# Copyright (C)2013-2014 the OpenProject Foundation (OPF)
# Copyright (C)2011 Stephan Eckardt, Tim Felgentreff, Marnen Laibow-Koser, Sandro Munda
# Copyright (C)2010-2011 friflaj
# Copyright (C)2010 Maxime Guilbot, Andrew Vit, Joakim Kolsjö, ibussieres, Daniel Passos, Jason Vasquez, jpic, Emiliano Heyns
# Copyright (C)2009-2010 Mark Maglana
# Copyright (C)2009 Joe Heck, Nate Lowrie
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License version 3.
#
# OpenProject Backlogs is a derivative work based on ChiliProject Backlogs.
# The copyright follows:
# Copyright (C) 2010-2011 - Emiliano Heyns, Mark Maglana, friflaj
# Copyright (C) 2011 - Jens Ulferts, Gregor Schmidt - Finn GmbH - Berlin, Germany
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

module RbMasterBacklogsHelper
  include Redmine::I18n

  def render_backlog_menu(backlog)
    content_tag(:div, class: 'menu') do
      [
        content_tag(:div, '', class: "menu-trigger icon-context icon-pulldown icon-small"),
        content_tag(:ul, class: 'items') do
          backlog_menu_items_for(backlog).map { |item|
            content_tag(:li, item, class: 'item')
          }.join.html_safe
        end
      ].join.html_safe
    end
  end

  def backlog_menu_items_for(backlog)
    items = common_backlog_menu_items_for(backlog)

    if backlog.sprint_backlog?
      items.merge!(sprint_backlog_menu_items_for(backlog))
    end

    menu = []
    [:new_story, :stories_tasks, :task_board, :burndown, :cards, :wiki, :configs, :properties].each do |key|
      menu << items[key] if items.keys.include?(key)
    end

    menu
  end

  def common_backlog_menu_items_for(backlog)
    items = {}

    items[:new_story] = content_tag(:a,
                                    l('backlogs.add_new_story'),
                                    href: '#',
                                    class: 'add_new_story')

    items[:stories_tasks] = link_to(l(:label_stories_tasks),
                                    controller: '/rb_queries',
                                    action: 'show',
                                    project_id: @project,
                                    sprint_id: backlog.sprint)

    if @export_card_config_meta[:count] > 0
      items[:configs] = export_export_cards_link(backlog)
    end

    if current_user.allowed_to?(:manage_versions, @project)
      items[:properties] = properties_link(backlog)
    end

    items
  end

  def export_export_cards_link(backlog)
    if @export_card_config_meta[:count] == 1
      link_to(l(:label_backlogs_export_card_export),
              controller: '/rb_export_card_configurations',
              action: 'show',
              project_id: @project,
              sprint_id: backlog.sprint,
              id: @export_card_config_meta[:default],
              format: :pdf)
    else
      export_modal_link(backlog)
    end
  end

  def properties_link(backlog)
    back_path = backlogs_project_backlogs_path(@project)

    version_path = edit_version_path(backlog.sprint, back_url: back_path)

    link_to(l(:'backlogs.properties'), version_path)
  end

  def export_modal_link(backlog, options = {})
    path = backlogs_project_sprint_export_card_configurations_path(@project.id, backlog.sprint.id)
    html_id = "modal_work_package_#{SecureRandom.hex(10)}"
    link_to(l(:label_backlogs_export_card_export), path, options.merge(id: html_id, :'data-modal' => ''))
  end

  def sprint_backlog_menu_items_for(backlog)
    items = {}

    items[:task_board] = link_to(l(:label_task_board),
                                 controller: '/rb_taskboards',
                                 action: 'show',
                                 project_id: @project,
                                 sprint_id: backlog.sprint)

    if backlog.sprint.has_burndown?
      items[:burndown] = content_tag(:a,
                                     l('backlogs.show_burndown_chart'),
                                     href: '#',
                                     class: 'show_burndown_chart')
    end

    if @project.module_enabled? 'wiki'
      items[:wiki] = link_to(l(:label_wiki),
                             controller: '/rb_wikis',
                             action: 'edit',
                             project_id: @project,
                             sprint_id: backlog.sprint)
    end

    items
  end
end
