
open Types

let string_of_const m v =
  if ident_eq m !Global.name then string_of_ident v
  else string_of_ident m ^ "." ^ string_of_ident v

let rec string_of_pterm = function
  | P_Type _                    -> "Type"
  | P_Id (_,v)                  -> string_of_ident v
  | P_QId (_,m,v)               -> string_of_ident m ^ "." ^ string_of_ident v
  | P_App args                  -> String.concat " " (List.map string_of_pterm_wp args)
  | P_Lam (_,v,a,b)             -> string_of_ident v ^ ":" ^ string_of_pterm_wp a ^ " => " ^ string_of_pterm b
  | P_Pi (None,a,b)             -> string_of_pterm_wp a ^ " -> " ^ string_of_pterm b
  | P_Pi (Some (_,v),a,b)       -> string_of_ident v ^ ":" ^ string_of_pterm_wp a ^ " -> " ^ string_of_pterm b
  | P_Unknown _                 -> "_"
and string_of_pterm_wp = function
 | P_Type _ | P_Id _ | P_QId _ | P_Unknown _ as t -> string_of_pterm t
 | t                                            -> "(" ^ string_of_pterm t ^ ")"

let rec string_of_term = function
  | Kind                        -> "Kind"
  | Type                        -> "Type"
  | DB  (x,n)                   -> string_of_ident x^"["^string_of_int n^"]"
  | Const (m,v)                 -> string_of_const m v
  | App args                    -> String.concat " " (List.map string_of_term_wp args)
  | Lam (x,a,f)                 -> string_of_ident x ^ ":" ^ string_of_term_wp a ^ " => " ^ string_of_term f
  | Pi  (None,a,b)              -> string_of_term_wp a ^ " -> " ^ string_of_term b
  | Pi  (Some x,a,b)            -> string_of_ident x ^ ":" ^   string_of_term_wp a ^ " -> " ^ string_of_term b
  | Meta _                      -> "_"
and string_of_term_wp = function
  | Kind | Type _  | DB _ | Const _ | Meta _ as t -> string_of_term t
  | t   -> "(" ^ string_of_term t ^ ")"

let rec string_of_pattern = function
  | Var (id,v)          -> string_of_ident id ^ "[" ^ string_of_int v ^ "]"
  | Joker _             -> "_"
  | Pattern (m,v,arr)   -> string_of_const m v ^ " " ^ String.concat " " (List.map string_of_pattern_wp (Array.to_list arr))
and string_of_pattern_wp = function
  | Var _ | Joker _ as p -> string_of_pattern p
  | p                   -> "(" ^ string_of_pattern p ^ ")"

let tab t = String.make (t*4) ' '

let rec str_of_gdt (t,b) = function
  | Test ([],te,_)              -> tab t ^ (if b then "else " else "") ^ string_of_term te
  | Test (lst,te,def)           ->
      begin
        let str =
          tab t ^ "if "
          ^ String.concat " and " (List.map (fun (i,j) -> "$"^string_of_int i^"=$"^string_of_int j^"" ) lst)
          ^ " then " ^ string_of_term te
        in
          match def with
            | None      -> str
            | Some g    -> str ^ "\n" ^ str_of_gdt (t,true) g
      end
    | Switch (i,cases,def)      ->
        begin
          let str_lst = List.map (fun ((m,v),g) -> "if $"^string_of_int i^"="^string_of_const m v^" then\n" ^ str_of_gdt (t+1,false) g ) cases in
          let str = tab t ^ String.concat "\n" str_lst in
            match def with
              | None    -> str
              | Some g  -> str ^ "\n" ^str_of_gdt (t,true) g
        end

let string_of_gdt m v i g =
  "GDT for " ^ string_of_const m v ^ " with " ^ string_of_int i ^ " argument(s):\n"
  ^ str_of_gdt (0,false) g