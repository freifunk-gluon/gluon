module("luci.tools.freifunk-wizard.nav", package.seeall)

function maybe_redirect_to_successor()
  local pre, suc = get()

  if suc then
          luci.http.redirect(luci.dispatcher.build_url("wizard", suc.href))
        end
end

function get()

        local disp = require "luci.dispatcher"

        local request  = disp.context.path
        local category = request[1]
        local cattree  = category and disp.node(category)

  local childs = disp.node_childs(cattree)

  local predecessor = nil
  local successor = nil

        if #childs > 0 then
          local found_pre = false
          for i, r in ipairs(childs) do
                  local nnode = cattree.nodes[r]
                  nnode.href = r

                        if r == request[2] then
                          found_pre = true
                        elseif found_pre and successor == nil then
                          successor = nnode
                        end

                        if not found_pre then
                          predecessor = nnode
                        end
                end
        end

        return predecessor, successor
end
