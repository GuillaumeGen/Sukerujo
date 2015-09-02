(** Global Environment *)

open Basics
open Term
open Rule

val ignore_redecl       : bool ref
val autodep             : bool ref

type signature_error =
  | FailToCompileModule of loc*ident
  | UnmarshalBadVersionNumber of loc*string
  | UnmarshalSysError of loc*string*string
  | UnmarshalUnknown of loc*string
  | SymbolNotFound of loc*ident*ident
  | AlreadyDefinedSymbol of loc*ident
  | CannotBuildDtree of Dtree.dtree_error
  | CannotAddRewriteRules of loc*ident
  | ConfluenceErrorImport of loc*ident*Confluence.confluence_error
  | ConfluenceErrorRules of loc*rule_infos list*Confluence.confluence_error

exception SignatureError of signature_error

type t

val make                : ident -> t
val get_name            : t -> ident

val export              : t -> bool
val get_type            : t -> loc -> ident -> ident -> term
val is_constant         : t -> loc -> ident -> ident -> bool
val get_dtree           : t -> loc -> ident -> ident -> (int*dtree) option
val add_declaration     : t -> loc -> ident -> term -> unit
val add_definable       : t -> loc -> ident -> term -> unit
val add_rules           : t -> Rule.rule2 list -> unit