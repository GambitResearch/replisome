#ifndef _REPLISOME_H_
#define _REPLISOME_H_

#include "postgres.h"

#include "utils/hsearch.h"

#include "includes.h"

#ifndef REPLISOME_VERSION
#define REPLISOME_VERSION unknown
#endif

typedef struct JsonDecodingData
{
	MemoryContext context;
	bool		include_xids;		/* include transaction ids */
	bool		include_timestamp;	/* include transaction timestamp */
	bool		include_schemas;	/* qualify tables */
	bool		include_types;		/* include data types */

	bool		pretty_print;		/* pretty-print JSON? */
	bool		write_in_chunks;	/* write in chunks? */

	/*
	 * LSN pointing to the end of commit record + 1 (txn->end_lsn)
	 * It is useful for tools that wants a position to restart from.
	 */
	bool		include_lsn;		/* include LSNs */
	bool		include_empty_xacts;	/* emit empty transactions too */

	uint64		nr_changes;			/* # of passes in pg_decode_change() */
									/* FIXME replace with txn->nentries */

	InclusionCommands *commands;	/* tables to include/exclude */
	HTAB *reldata;					/* details about tables processed */

} JsonDecodingData;

#endif
