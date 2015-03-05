-- Alba Guardado Garcia

with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

	procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_A);



	-- Dada una key, devuelve el value asociado a la misma en caso de que ese elemento exista

	procedure Get (M       : Map;
						Key     : in  Key_Type;
						Value   : out Value_Type;
						Success : out Boolean) is
		P_Aux : Cell_A;
	begin
		P_Aux := M.P_First;
		Success := False;
		while not Success and P_Aux /= null Loop
			if P_Aux.Key = Key then
				Value := P_Aux.Value;
				Success := True;
			end if;
			P_Aux := P_Aux.Next;
		end loop;
	end Get;




	-- Dado un nuevo elemento (key, value) se añade a la tabla. 
	-- Si la key ya existia se remplaza la value nueva
	-- Cuando no se ha podido añadir un nuevo elemento a la tabla por el Max_Length => Succes:= True;

	procedure Put (	M     : in out Map;  -- My_Neighs (mi lista)
					Key   : Key_Type;
					Value : Value_Type; 
					Success: out Boolean) is
		P_Aux : Cell_A;
		Found : Boolean;
		P_New : Cell_A;
	begin
		Success:= False;
			
		-- Si ya existe Key, cambiamos su Value
		P_Aux := M.P_First;
		Found := False;
		while ((not Found) and (P_Aux /= null)) loop
			if P_Aux.Key = Key then
				Success:= True; 
				P_Aux.Value := Value;
				Found := True;
			 end if;
			 P_Aux := P_Aux.Next;
		end loop;


		-- Si no hemos encontrado Key añadimos por el final
		if not Found then	
			--P_New := new Cell'(null, Key, Value, M.P_First);
			if (M.Length /= Max_Length) then
				Success:= True; 
				
				P_New := new Cell;
				P_New.all.Key:= key;
				P_New.all.Value:= Value;
				P_New.all.Next:= null;
				
				if (M.P_First = null) then
					P_New.all.Prev:= null;
					M.P_First:= P_New;
					M.P_Last:= P_New;
					
				else
					P_New.all.Prev:= M.P_Last;
					M.P_Last.Next:= P_New;
					M.P_Last:= P_New;
				
				end if;
				M.Length := M.Length + 1;
			end if;
		end if;
	end Put;


	-- Dada una key, se borra de la tabla la key y el value asociado a dicha key

	procedure Delete (M      : in out Map;
							Key     : in  Key_Type;
							Success : out Boolean) is
		P_Current  : Cell_A; -- el que quiero borrar

	begin

		Success := False;
		P_Current  := M.P_First;

		while not Success and P_Current /= null  loop
			if P_Current.Key = Key then
				Success := True;
				M.Length := M.Length - 1;
				
				if P_Current.Prev = null then
					M.P_First := P_Current.Next;
				else
					P_Current.Prev.Next := P_Current.Next;
				end if;
				
				if P_Current.Next = null then
					M.P_Last := P_Current.Prev;
				else
					P_Current.Next.Prev := P_Current.Prev;
				end if;
				
				Free (P_Current);
			else
				P_Current := P_Current.Next; 
			end if;
	end loop;

	end Delete;

	

	function Get_Keys (M: Map) return Keys_Array_Type is
		P_Aux: Cell_A;
		Keys_Array: Keys_Array_Type;
		i: Integer:= 1; 
	begin
		P_Aux := M.P_First;
		while (P_Aux /= null) loop
			Keys_Array(i):= P_Aux.Key;
			i:= i + 1; 
			P_Aux:= P_Aux.Next;
		end loop;
		
		
		while (i /= Max_Length) loop
			Keys_Array(i):= Null_Key;
			i:= i + 1;
		end loop;
		
		return Keys_Array;
	end Get_Keys;
   
   
	function Get_Values (M: Map) return Values_Array_Type is
		P_Aux: Cell_A;
		Values_Array: Values_Array_Type;
		i: Integer:= 1; 
	begin
		P_Aux := M.P_First;
		while (P_Aux /= null) loop
			Values_Array(i):= P_Aux.Value;
			i:= i + 1; 
			P_Aux:= P_Aux.Next;
		end loop;
		
		while (i /= Max_Length) loop
			Values_Array(i):= Null_Value;
			i:= i + 1;
		end loop;
		
		return Values_Array;
	end Get_Values;


	function Map_Length (M : Map) return Natural is
	begin
		return M.Length;
	end Map_Length;
	
	

	procedure Print_Map (M : Map) is
		P_Aux : Cell_A;
	begin
		P_Aux := M.P_First;
		
		while P_Aux /= null loop
			Ada.Text_IO.Put_Line ("                [ " & Key_To_String(P_Aux.Key) & ", " &
									     Value_To_String(P_Aux.Value) & " ]");
			P_Aux := P_Aux.Next;
		end loop;
	end Print_Map;

end Maps_G;
