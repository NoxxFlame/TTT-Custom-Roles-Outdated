function CreateFavTable()
    if not (sql.TableExists("ttt_bem_fav")) then
        sql.Query("CREATE TABLE ttt_bem_fav (guid TEXT, role TEXT, weapon_id TEXT)")
    else
        print("ALREADY EXISTS")
    end
end

function AddFavorite(guid, role, weapon_id)
    sql.Query("INSERT INTO ttt_bem_fav VALUES('" .. guid .. "','" .. role .. "','" .. weapon_id .. "')")
end

function RemoveFavorite(guid, role, weapon_id)
    sql.Query("DELETE FROM ttt_bem_fav WHERE guid = '" .. guid .. "' AND role = '" .. role .. "' AND weapon_id = '" .. weapon_id .. "'")
end

function GetFavorites(guid, role)
    return sql.Query("SELECT weapon_id FROM ttt_bem_fav WHERE guid = '" .. guid .. "' AND role = '" .. role .. "'")
end

-- looks for weapon id in favorites table (result of GetFavorites)
function IsFavorite(favorites, weapon_id)
    for _, value in pairs(favorites) do
        local dbid = value["weapon_id"]
        if (dbid == tostring(weapon_id)) then
            return true
        end
    end
    return false
end
