//

package org.example;

import org.javalite.activejdbc.Model;
import org.javalite.activejdbc.annotations.VersionColumn;

@VersionColumn("lock_version")
public class Item extends Model {
    public static Item fetch(int id) {
        return Item.findById(id);
    }

    public void setTitle(String t) {
        this.set("title", t);
    }
}
