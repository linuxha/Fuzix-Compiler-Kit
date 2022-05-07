/*
 *	Declaration handling. All cases are actually the same, including
 *	typedef (hence the weird typedef syntax)
 *
 *	We don't deal with the comma cases yet (ie int a, *b)
 */

#include "compiler.h"

void dotypedef(void)
{
	unsigned name;
	unsigned type = type_and_name(&name, 1, UNKNOWN);
	struct symbol *sym;
	if (type == UNKNOWN || name == 0) {
		error("invalid typedef");
		junk();
		return;
	}
	sym = find_symbol(name);
	if (sym) {
		error("name already in use");
		return;
	}
	sym = alloc_symbol(name, 0);
	sym->type = type;
	sym->storage = S_TYPEDEF;
	sym->name = name;
}

void declaration(unsigned defstorage)
{
	unsigned type;
	unsigned name;
	unsigned s = get_storage(defstorage);
	struct symbol *sym;
	struct symbol *ltop;
	unsigned argsave, locsave;

	/* Create a local symbol context for the arguments - there are
	   local names for the function case */
	ltop = mark_local_symbols();
	mark_storage(&argsave, &locsave);
	type = type_and_name(&name, 0, CINT);

	/* It's quite valid C to just write "int;" but usually dumb except
	   that it's used for struct and union */
	if (name == 0) {
		if (!IS_STRUCT(type))
			warning("useless declaration");
		pop_storage(&argsave, &locsave);
		pop_local_symbols(ltop);
		need_semicolon();
		return;
	}

	if (s == S_AUTO && defstorage == S_EXTDEF)
		error("no automatic globals");

	if (IS_FUNCTION(type) && !PTR(type)) {
		if (token == T_LCURLY) {
			if (s == S_EXTDEF)
				header(H_EXPORT, name, 0);
			function_body(s, name, type);
			pop_local_symbols(ltop);
			pop_storage(&argsave, &locsave);
			return;
		} else if (s == S_EXTDEF)
			s = S_EXTERN;
	}
	pop_local_symbols(ltop);
	pop_storage(&argsave, &locsave);

	/* Do we already have this symbol */
	sym = update_symbol(name, s, type);

	if (sym->flags & INITIALIZED)
		error("duplicate initializer");
	if ((PTR(type) || !IS_FUNCTION(type)) && match(T_EQ)) {
		sym->flags |= INITIALIZED;
		if (s >= S_LSTATIC)
		        header(H_DATA, sym->name, target_alignof(type));
		initializers(sym, type, s);
		if (s >= S_LSTATIC)
		        footer(H_DATA, sym->name, 0);
	}
	if (s == AUTO)
		sym->offset = assign_storage(type, S_AUTO);
	need_semicolon();
}