function struct = rename_struct_fieldname(struct,old_fieldname,new_fieldname)

[struct.(new_fieldname)] = struct.(old_fieldname);
struct = rmfield(struct,old_fieldname);