#!<%= ENV['SHELL'] || '/bin/bash' %>
tmux <%= socket %> start-server

if ! $(tmux <%= socket %> start-server \\\; has-session -t <%=s @project_name %>); then
cd <%= @project_root || "." %>
<%= @pre.kind_of?(Array) ? @pre.join(" && ") : @pre %>
env TMUX= tmux <%= socket %> start-server \; new-session -d -s <%=s @project_name %> -n <%=s @tabs[0].name %>
tmux <%= socket %> set-option -t <%=s @project_name %> default-path <%= @project_root %>

<% @tabs[1..-1].each_with_index do |tab, ti| %>
<% i = ti + @base_index + 1 %>
tmux <%= socket %> new-window -t <%= window(i) %> -n <%=s tab.name %>
<% end %>

# set up tabs and panes
<% @tabs.each_with_index do |tab, ti| %>
<% i = ti + @base_index %>
# tab "<%= tab.name %>"
<%   if tab.command %>
<%=    send_keys(tab.command, i) %>
<%   elsif tab.panes %>
<%=    send_keys(tab.panes.shift, i) %>
<%     tab.panes.each do |pane| %>
tmux <%= socket %> splitw -t <%= window(i) %>
<%=      send_keys(pane, i) %>
<%     end %>
tmux <%= socket %> select-layout -t <%= window(i) %> <%=s tab.layout %>
tmux <%= socket %> select-pane -t <%= window(i) %>.0
<%   end %>
<% end %>

tmux <%= socket %> select-window -t <%= window(@base_index) %>

fi

if [ -z $TMUX ]; then
    tmux <%= cli_args %> <%= socket %> -u attach-session -t <%=s @project_name %>
else
    tmux <%= socket %> -u switch-client -t <%=s @project_name %>
fi
