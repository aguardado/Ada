-- Alba Guardado Garcia

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Handler;
with Seq_N_T;
with Pantalla;
with Ada.Calendar;
with Image_EP;
with Debug;
--P5
with Timed_Handlers;
with Others_P5;


procedure chat_peer is

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package CM renames Chat_Messages;
	package Seq renames Seq_N_T;
	package Othrs renames Others_P5;

	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type Seq.Seq_N_T;
	--use type Ada.Calendar.Time;
	--use type Othrs.Buffer_A_T;
	

	Usage_Error: exception;
	
	
	procedure Muestra_H  is
	begin
		Pantalla.Poner_Color(Pantalla.Rojo);
		Ada.Text_IO.Put_Line("              Comandos                Efectos");
		Ada.Text_IO.Put_Line("              ================        ========");
		Ada.Text_IO.Put_Line("              .nb .neighbors          lista de vecinos");
		Ada.Text_IO.Put_Line("              .lm .latest_msgs        lista de últimos mensajes recibidos");
		Ada.Text_IO.Put_Line("              .sd                     lista de sender dests");
		Ada.Text_IO.Put_Line("              .sb                     lista de sender buffering");
		Ada.Text_IO.Put_Line("              .debug                  toggle para info de debug");
		Ada.Text_IO.Put_Line("              .wai .whoami            Muestra en pantalla: nick | EP_H | EP_R");
		Ada.Text_IO.Put_Line("              .h .help                muestra esta información de ayuda");
		Ada.Text_IO.Put_Line("              .salir                  termina el programa");
		Pantalla.Poner_Color(Pantalla.Cierra);
	end Muestra_H ;
	
   
	procedure Meto_Init (	P_Buffer: access LLU.Buffer_Type; EP_H_Creat: LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T;
									EP_H_Rsnd: LLU.End_Point_Type; EP_R_Creat: LLU.End_Point_Type;  
									Nick: ASU.Unbounded_String) is
		Mess: CM.Message_Type;
	begin
		Mess:= CM.Init;
		Seq_N:= Seq_N + 1;
		LLU.Reset(P_Buffer.all);
		
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Creat);
		Seq.Seq_N_T'Output(P_Buffer, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Rsnd);
		LLU.End_Point_Type'Output(P_Buffer, EP_R_Creat);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
	end Meto_Init;
	
	
	procedure Meto_Confirm (P_Buffer: access LLU.Buffer_Type; EP_H_Creat: LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T;
									EP_H_Rsnd: LLU.End_Point_Type; Nick: ASU.Unbounded_String) is
		Mess: CM.Message_Type;
	begin
		Mess:= CM.Confirm;
		Seq_N:= Seq_N + 1;
		LLU.Reset(P_Buffer.all);
		
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Creat);
		Seq.Seq_N_T'Output(P_Buffer, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Rsnd);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
	end Meto_Confirm;
	
	
	procedure Meto_Logout (P_Buffer: access LLU.Buffer_Type; EP_H_Creat: LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T;
									EP_H_Rsnd: LLU.End_Point_Type; Nick: ASU.Unbounded_String; Confirm_Sent: Boolean) is
		Mess: CM.Message_Type;
	begin
		Mess:= CM.Logout;
		Seq_N:= Seq_N + 1;
		LLU.Reset(P_Buffer.all);
		
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Creat);
		Seq.Seq_N_T'Output(P_Buffer, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Rsnd);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
		Boolean'Output(P_Buffer, Confirm_Sent);
	end Meto_Logout;
	
	
	procedure Meto_Writer (P_Buffer: access LLU.Buffer_Type; EP_H_Creat: LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T;
									EP_H_Rsnd: LLU.End_Point_Type; Nick: ASU.Unbounded_String; Texto: ASU.Unbounded_String) is
		Mess: CM.Message_Type;
	begin
		Mess:= CM.Writer;
		Seq_N:= Seq_N + 1;
		LLU.Reset(P_Buffer.all);
		
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Creat);
		Seq.Seq_N_T'Output(P_Buffer, Seq_N);
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Rsnd);
		ASU.Unbounded_String'Output(P_Buffer, Nick);
		ASU.Unbounded_String'Output(P_Buffer, Texto);
	end Meto_Writer;
	
	
	function Activacion_Debug (Status: Boolean) return Boolean is
	begin
		if (Status = True) then
			return False;
		else
			return True;
		end if;
	end Activacion_Debug;
	
	
	
	procedure Peer_Admitido (	Nick: in out ASU.Unbounded_String; 
										EP_H_Creat: LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T;
										EP_H_Rsnd: LLU.End_Point_Type; Confirm_Sent: in out Boolean;
										EP_R: LLU.End_Point_Type) is
		Comentario: ASU.Unbounded_String;
		Array_EP: Handler.Neighbor.Keys_Array_Type;
		Longitud_Lista: Natural;
		Success: Boolean:= False;
		Longitud: Natural:= 0;
		Status: Boolean:= True;
		Plazo_Retransmision: Duration:= Duration(0);
		Hora_Retransmision: Ada.Calendar.Time;
		--Value_Sender_Buffering: Othrs.Value_T;
		Key_Sender_Dests: Othrs.Mess_Id_T;
		Value_Sender_Dests: Othrs.Destinations_T;
		Hora_Delay: Duration;
	begin
		Pantalla.Poner_Color(Pantalla.Azul);
		
		Ada.Text_IO.Put_Line("Peer-Chat v1.0");
		Ada.Text_IO.Put_Line("==============");
		Ada.Text_IO.New_Line;
		Ada.Text_IO.Put_Line("Entramos en el chat con el Nick: " & ASU.To_String(Nick));
		Ada.Text_IO.Put_Line(".h para help");
		
		loop
				Pantalla.Poner_Color(Pantalla.Azul);
				Comentario:= ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				Pantalla.Poner_Color(Pantalla.Azul);
				
				Longitud:= ASU.Length(Comentario); 
				
				if (Longitud /= 0) and then (Comentario /= " ") then
					if ((Comentario = ".h") or (Comentario = ".help"))then
						Muestra_H;
						
					elsif ((Comentario = ".nb") or (Comentario = ".neighbors"))then
						Pantalla.Poner_Color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("                  Neighbors");
						Ada.Text_IO.Put_Line("                  ------------------------");
						Handler.Neighbor.Print_Map (Handler.My_Neighs);
						Pantalla.Poner_Color(Pantalla.Cierra);
						
					elsif ((Comentario = ".lm") or (Comentario = ".latest_msgs"))then
						Pantalla.Poner_Color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("                  Latest_Msgs");
						Ada.Text_IO.Put_Line("                  ------------------------");
						Handler.Latest_Msgs.Print_Map (Handler.My_Msgs);
						Pantalla.Poner_Color(Pantalla.Cierra);
						
					elsif ((Comentario = ".wai") or (Comentario = ".whoami"))then
						Pantalla.Poner_Color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("Nick: " & ASU.To_String(Handler.Nick_usuario));
						Ada.Text_IO.Put_Line("EP_H: " & Image_EP.Image(Handler.EP_H));
						Ada.Text_IO.Put_Line("EP_R: " & Image_EP.Image(EP_R));
						Pantalla.Poner_Color(Pantalla.Cierra);
						
					elsif (Comentario = ".sb") then
						Pantalla.Poner_Color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("                  Sender_Buffering");
						Ada.Text_IO.Put_Line("                  ------------------------");
						Handler.Sender_Buffering.Print_Map (Handler.My_SB_Map);
						Pantalla.Poner_Color(Pantalla.Cierra);
					
					elsif (Comentario = ".sd") then
						Pantalla.Poner_Color(Pantalla.Rojo);
						Ada.Text_IO.Put_Line("                  Sender_Dests");
						Ada.Text_IO.Put_Line("                  ------------------------");
						Handler.Sender_Dests.Print_Map (Handler.My_SD_Map);
						Pantalla.Poner_Color(Pantalla.Cierra);
						
					elsif (Comentario = ".salir") then
						Confirm_Sent:= True;
						CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
						Meto_Logout (CM.P_Buffer_Main, EP_H_Creat, Seq_N, EP_H_Rsnd, Nick, Confirm_Sent);
						
						Array_EP:= Handler.Neighbor.Get_Keys (Handler.My_Neighs);
						Longitud_Lista:= Handler.Neighbor.Map_Length(Handler.My_Neighs);
						
						
						Debug.Put("FLOOD LOGOUT ", Pantalla.Azul_Claro);
						for k in 1..Longitud_Lista loop
							LLU.Send(Array_EP(k), CM.P_Buffer_Main);
							Value_Sender_Dests(k).EP:= Array_EP(k);
							
							if Confirm_Sent = True then
								Debug.Put_Line(Image_EP.Image(Handler.EP_H) & " " & Seq.Seq_N_T'Image(Seq_N) & 
													" " & ASU.To_String(Nick) & " send to " & Image_EP.Image(Array_EP(k)) & " TRUE" , Pantalla.Verde);
							else
								Debug.Put_Line(Image_EP.Image(Handler.EP_H) & " " & Seq.Seq_N_T'Image(Seq_N) & 
													" " & ASU.To_String(Nick) & " send to " & Image_EP.Image(Array_EP(k)) & " FALSE" , Pantalla.Verde);
							end if;
						end loop;
						
						if (Longitud_Lista < Value_Sender_Dests'Last) then
							for K in Longitud_Lista + 1 .. Value_Sender_Dests'Last loop
								value_Sender_Dests(K).EP := Array_EP(K);
							end loop;	
						end if;
						
						Handler.Put_Sender_Buffering (CM.P_Buffer_Main, Plazo_Retransmision, Hora_Retransmision, EP_H_Creat, Seq_N);
						Handler.Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, EP_H_Creat, Seq_N);
						
						Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
						
						Hora_Delay:= 10 * Plazo_Retransmision;
						delay Hora_Delay;
						
					elsif (Comentario = ".debug") then
						Status:= Activacion_Debug(Status);
						Debug.Set_Status(Status); --Me desactiva(FALSE)/activa(TRUE) los debug
						
					else
						
						CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
						Meto_Writer (CM.P_Buffer_Main, EP_H_Creat, Seq_N, EP_H_Rsnd, Nick, Comentario);
						
						Handler.Latest_Msgs.Put (Handler.My_Msgs, Handler.EP_H, Seq_N, Success);
						Debug.Put_Line("Añadimos a latest_messages " & Image_EP.Image(Handler.EP_H) & Seq.Seq_N_T'Image(Seq_N), Pantalla.Verde);
						
						Array_EP:= Handler.Neighbor.Get_Keys (Handler.My_Neighs);
						Longitud_Lista:= Handler.Neighbor.Map_Length(Handler.My_Neighs);
						
						
						
						Debug.Put("FLOOD WRITER ", Pantalla.Azul_Claro);
						Ada.Text_IO.New_Line;
						for k in 1..Longitud_Lista loop
							LLU.Send(Array_EP(k), CM.P_Buffer_Main);
							Value_Sender_Dests(k).EP:= Array_EP(k);
							Debug.Put_Line(Image_EP.Image(Handler.EP_H) & " " & Seq.Seq_N_T'Image(Seq_N) & 
												" " & ASU.To_String(Nick) & " " & ASU.To_String(Comentario) , Pantalla.Verde);
						end loop;
						
						if (Longitud_Lista < Value_Sender_Dests'Last) then
							for K in Longitud_Lista + 1 .. Value_Sender_Dests'Last loop
								value_Sender_Dests(K).EP := Array_EP(K);
							end loop;	
						end if;
						
						Handler.Put_Sender_Buffering (CM.P_Buffer_Main, Plazo_Retransmision, Hora_Retransmision, EP_H_Creat, Seq_N);
						Handler.Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, EP_H_Creat, Seq_N);
						
						Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
						
					end if;
				end if;
			exit when (Comentario = ".salir");
			end loop;
			Pantalla.Poner_Color(Pantalla.Cierra);
	end Peer_Admitido;
	
	
	
	procedure Funcionamiento_Peer (	P_Buffer: access LLU.Buffer_Type; Seq_N: in out Seq.Seq_N_T; EP_R: in out LLU.End_Point_Type;
												Array_EP: in out Handler.Neighbor.Keys_Array_Type; Longitud_Lista: in out Natural;
												Success: in out Boolean; Expired: in out Boolean; Confirm_Sent: in out Boolean; 
												Mess: in out CM.Message_Type; EP_H_Reject : in out LLU.End_Point_Type; 
												Nick: in out ASU.Unbounded_String)is
		Plazo_Retransmision: Duration:= Duration(0);
		Hora_Retransmision: Ada.Calendar.Time;
		--Value_Sender_Buffering: Othrs.Value_T;
		Key_Sender_Dests: Othrs.Mess_Id_T;
		Value_Sender_Dests: Othrs.Destinations_T;
	begin
			-- Comienzo protocolo de admision
			Ada.Text_IO.New_Line;
			Debug.Put_Line("Iniciando Protocolo de Admisión ...", Pantalla.Verde);
			
			CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
			Meto_Init (CM.P_Buffer_Main, Handler.EP_H, Seq_N, Handler.EP_H, EP_R, Handler.Nick_Usuario); --sumo +1 el Seq_N
			
			--Envio por inundacion con get_keys
			Array_EP:= Handler.Neighbor.Get_Keys (Handler.My_Neighs);
			Longitud_Lista:= Handler.Neighbor.Map_Length(Handler.My_Neighs);
			
			Key_Sender_Dests.EP:= Handler.EP_H;
			Key_Sender_Dests.NSeq:= Seq_N;
			
			
			for k in 1..Longitud_Lista loop
				LLU.Send(Array_EP(k), CM.P_Buffer_Main);
				Value_Sender_Dests(k).EP:= Array_EP(k);
				Debug.Put("FLOOD INIT ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(Handler.EP_H) & "... " & ASU.To_String(Handler.Nick_Usuario) &
								 " send to " & Image_EP.Image(Array_EP(k)), Pantalla.Verde);
			end loop;
			
			Handler.Put_Sender_Buffering (CM.P_Buffer_Main, Plazo_Retransmision, Hora_Retransmision, Handler.EP_H, Seq_N);
			Handler.Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, Handler.EP_H, Seq_N);
			
			Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
			
			Handler.Latest_Msgs.Put (Handler.My_Msgs, Handler.EP_H, Seq_N, Success);
			Debug.Put_Line("Añadimos a latest_messages " & Image_EP.Image(Handler.EP_H) & Seq.Seq_N_T'Image(Seq_N), Pantalla.Verde);
			
			LLU.Receive (EP_R, P_Buffer, 2.0, Expired); --Espero el reject
			
			if Expired then
				-- Envio mensaje confirm y me meto en el chat
				CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
				Meto_Confirm (CM.P_Buffer_Main, Handler.EP_H, Seq_N, Handler.EP_H, Handler.Nick_Usuario); --sumo +1 el Seq_N
				Handler.Latest_Msgs.Put (Handler.My_Msgs, Handler.EP_H, Seq_N, Success);
				
				Ada.Text_IO.New_Line;
				Debug.Put_Line("Añadimos a latest_messages " & Image_EP.Image(Handler.EP_H) & Seq.Seq_N_T'Image(Seq_N), Pantalla.Verde);
				
				
				Array_EP:= Handler.Neighbor.Get_Keys (Handler.My_Neighs);
				Longitud_Lista:= Handler.Neighbor.Map_Length(Handler.My_Neighs);
				
				for k in 1..Longitud_Lista loop
					LLU.Send(Array_EP(k), CM.P_Buffer_Main);
					Value_Sender_Dests(k).EP:= Array_EP(k);
					Debug.Put("FLOOD CONFIRM ", Pantalla.Azul_Claro);
					Debug.Put_Line(Image_EP.Image(Handler.EP_H) & "... " & ASU.To_String(Handler.Nick_Usuario) &
								 " send to " & Image_EP.Image(Array_EP(k)), Pantalla.Verde);
				end loop;
				
				if (Longitud_Lista < Value_Sender_Dests'Last) then
					for K in Longitud_Lista + 1 .. Value_Sender_Dests'Last loop
						value_Sender_Dests(K).EP := Array_EP(K);
					end loop;	
				end if;
				
				Handler.Put_Sender_Buffering (CM.P_Buffer_Main, Plazo_Retransmision, Hora_Retransmision, Handler.EP_H, Seq_N);
				--Ada.Text_IO.Put_Line(Integer'Image(Handler.Sender_Dests.Map_Length(Handler.My_SD_Map)));
				Handler.Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, Handler.EP_H, Seq_N);
				--Handler.Sender_Buffering.Print_Map(Handler.My_SB_Map);
				--Handler.Sender_Dests.Print_Map (Handler.My_SD_Map);
				
				Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
				
				Ada.Text_IO.New_Line;
				Debug.Put_Line("Fin del Protocolo de Admisión.", Pantalla.Verde);
				
				Peer_Admitido(Handler.Nick_Usuario, Handler.EP_H, Seq_N, Handler.EP_H, Confirm_Sent, EP_R);
			else 
				Mess := CM.Message_Type'Input(P_Buffer);
				if (Mess = CM.Reject) then
				
					EP_H_Reject := LLU.End_Point_Type'Input (P_Buffer);
					Nick := ASU.Unbounded_String'Input (P_Buffer);
					
					Debug.Put("RCV REJECT ", Pantalla.Azul_Claro);
					Debug.Put_Line(Image_EP.Image(EP_H_Reject) & "  " & ASU.To_String(Nick), Pantalla.Verde);
					
					--Envia por inundacion un mensaje de tipo logout y se va;
					
					Confirm_Sent:= False; --RECHAZADO
					CM.P_Buffer_Main:= new LLU.Buffer_Type(1024);
					Meto_Logout (CM.P_Buffer_Main, Handler.EP_H, Seq_N, Handler.EP_H, Handler.Nick_Usuario, Confirm_Sent); --sumo +1 el Seq_N
					
					Array_EP:= Handler.Neighbor.Get_Keys (Handler.My_Neighs);
					Longitud_Lista:= Handler.Neighbor.Map_Length(Handler.My_Neighs);
					
					
					
					Debug.Put("FLOOD LOGOUT ", Pantalla.Azul_Claro);
					for k in 1..Longitud_Lista loop
						LLU.Send(Array_EP(k), CM.P_Buffer_Main);
						Value_Sender_Dests(k).EP:= Array_EP(k);
						
						if Confirm_Sent = True then
							Debug.Put_Line(Image_EP.Image(Handler.EP_H) & " " &  Seq.Seq_N_T'Image(Seq_N) 
												& " " & ASU.To_String(Handler.Nick_Usuario) & " TRUE" & " send to " &
												Image_EP.Image(Array_EP(k)), Pantalla.Verde);
						else
							Debug.Put_Line(Image_EP.Image(Handler.EP_H) & " " &  Seq.Seq_N_T'Image(Seq_N) 
												& " " & ASU.To_String(Handler.Nick_Usuario) & " TRUE" & " send to " &
												Image_EP.Image(Array_EP(k)), Pantalla.Verde);
						end if;
					end loop;
					
					if (Longitud_Lista < Value_Sender_Dests'Last) then
						for K in Longitud_Lista + 1 .. Value_Sender_Dests'Last loop
							value_Sender_Dests(K).EP := Array_EP(K);
						end loop;	
					end if;
					
					Handler.Put_Sender_Buffering (CM.P_Buffer_Main, Plazo_Retransmision, Hora_Retransmision, Handler.EP_H, Seq_N);
					Handler.Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, Handler.EP_H, Seq_N);
					
					Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
					
					Pantalla.Poner_Color(Pantalla.Blanco);
					Ada.Text_IO.Put_Line("Usuario rechazado porque " & Image_EP.Image(EP_H_Reject) & " está usando el mismo nick");
					Ada.Text_IO.New_Line;
					Debug.Put_Line("Fin del protocolo de Admisión.", Pantalla.Verde);
				end if;
			end if;
	end Funcionamiento_Peer;

	

	procedure Peer is
		Nick_Usuario, Nick: ASU.Unbounded_String;
		Buffer:    aliased LLU.Buffer_Type(1024);
		EP_R: LLU.End_Point_Type;  --REJECT
		EP_H_1, EP_H_2, EP_H_Reject: LLU.End_Point_Type; -- Vecinos
		
		Seq_N: Seq.Seq_N_T:= 0; 
		Clock: Ada.Calendar.Time;
		Success, Confirm_Sent: Boolean:= False;
		Expired: Boolean:= False;
		Array_EP: Handler.Neighbor.Keys_Array_Type;
		Longitud_Lista: Natural:= 0;
		Mess: CM.Message_Type:= CM.Init;
		
		Value_Sender_Dests: Othrs.Destinations_T;
	begin
		
		Handler.EP_H:= LLU.Build(LLU.TO_IP(LLU.Get_Host_Name), Integer'Value(Ada.Command_Line.Argument(1))); 
		LLU.Bind(Handler.EP_H, Handler.Client_Handler'Access); 
		LLU.Bind_Any(EP_R);
		
		Handler.Nick_Usuario:= ASU.To_Unbounded_String(Ada.Command_Line.Argument(2)); --Siempre va a ser el nick del propio nodo
		
		LLU.Set_Faults_Percent (Integer'Value(Ada.Command_Line.Argument(5))); --porcentaje de perdidas. Afecta tb al handler
		LLU.Set_Random_Propagation_Delay (Integer'Value(Ada.Command_Line.Argument(3)), Integer'Value(Ada.Command_Line.Argument(4)));--retardo en los mensajes enviados (tb afecta al handler)
		
	
		if (Ada.Command_Line.Argument_Count = 5) then 
		
				Pantalla.Poner_Color(Pantalla.Verde);
				Ada.Text_IO.Put_Line("NO hacemos protocolo de admisión pues no tenemos contactos iniciales");
				Pantalla.Poner_Color(Pantalla.Cierra);
				
				Peer_Admitido(Handler.Nick_Usuario, Handler.EP_H, Seq_N, Handler.EP_H, Confirm_Sent, EP_R);
			
		elsif (Ada.Command_Line.Argument_Count = 7) then  --Tengo un vecino
				
				EP_H_1 := LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(6)), Integer'Value(Ada.Command_Line.Argument(7)));
				
				Clock:= Ada.Calendar.Clock;
				Handler.Neighbor.Put (Handler.My_Neighs, EP_H_1, Clock, Success);
				
				Debug.Put_Line("Añadimos a neighbors " & Image_EP.Image(EP_H_1), Pantalla.Verde);
				
				
				Funcionamiento_Peer (Buffer'Access, Seq_N, EP_R, Array_EP, Longitud_Lista, 
											Success, Expired, Confirm_Sent, Mess, EP_H_Reject, Nick);
				
		elsif (Ada.Command_Line.Argument_Count = 9) then --Tengo dos vecinos
			
				EP_H_1:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(6)), Integer'Value(Ada.Command_Line.Argument(7)));
				EP_H_2:= LLU.Build(LLU.TO_IP(Ada.Command_Line.Argument(8)), Integer'Value(Ada.Command_Line.Argument(9)));
				
				--Añado vecinos a mi tabla de simbolos neighbors
				
				Clock:= Ada.Calendar.Clock;
				
				Handler.Neighbor.Put (Handler.My_Neighs, EP_H_1, Clock, Success);
				Handler.Neighbor.Put (Handler.My_Neighs, EP_H_2, Clock, Success);
				
				
				Debug.Put_Line("Añadimos a neighbors " & Image_EP.Image(EP_H_1), Pantalla.Verde);
				Debug.Put_Line("Añadimos a neighbors " & Image_EP.Image(EP_H_2), Pantalla.Verde);
				
				Funcionamiento_Peer (Buffer'Access, Seq_N, EP_R, Array_EP, Longitud_Lista, 
											Success, Expired, Confirm_Sent, Mess, EP_H_Reject, Nick);
		end if;
	end Peer;

   
begin

	if (Ada.Command_Line.Argument_Count /= 5) and then (Ada.Command_Line.Argument_Count /= 7) 
										and then (Ada.Command_Line.Argument_Count /= 9) then
		raise Usage_Error; 
	end if;
	
	Peer;
	LLU.Finalize;
	Timed_Handlers.Finalize;

exception
   when Usage_Error =>
      Ada.Text_IO.Put_Line ("uso OBLIGATORIO: chat_peer <nº puerto por el cual recibira los mensajes> <nickname> <min_delay> <max_delay> <fault_pct>");
      Ada.Text_IO.Put_Line ("uso OPCIONAL (vecinos): chat_peer <neighbor_host> <neighbor_host>");
   when Except:others =>
      Ada.Text_IO.Put_Line ("Excepción imprevista: " &
                              Ada.Exceptions.Exception_Name(Except) & " en: " & 
                              Ada.Exceptions.Exception_Message (Except)); 

	LLU.Finalize;
	Timed_Handlers.Finalize;
end chat_peer;
