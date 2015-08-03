open Basics
open Rule

(* val check_confluence    : ((string*out_channel) option) ref *)
val initialize : string -> unit

val check : unit -> bool
val add_constant : ident -> ident -> unit
val add_rules : rule_infos list -> unit
val check : unit -> (unit,string) error

val finalize : unit -> unit
