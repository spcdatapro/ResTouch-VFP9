FUNCTION verifica_evento ()
	PARAMETERS xqevento,xqproducto,xqcomanda,PrmCantidad
	PUBLIC xresp

	SELECT * FROM Evento WHERE evento=xqevento INTO CURSOR ElEvento
		
	LaNuevaCantidad=PrmCantidad
	*1. Verificar si el producto esta dentrol evento
	SELECT * FROM detalle_evento WHERE evento=xqevento AND producto=xqproducto INTO CURSOR cdetevento
	IF !EOF()  && Si esta en el evento el producto
		IF cdetevento.detalle
			SELECT a.subgrupo,b.detalle_producto,c.tipo FROM producto_menu a,detalle_producto b, subgrupo c ;
			WHERE detalle_producto=cdetevento.producto AND a.producto=b.producto AND a.subgrupo=c.subgrupo INTO CURSOR subgprodud
		ELSE
			SELECT a.subgrupo,c.tipo FROM producto_menu a, subgrupo c ;
			WHERE a.producto=cdetevento.producto AND a.subgrupo=c.subgrupo INTO CURSOR subgprodud
		endif		
		 
		* hago algo parecido en el detalle de la comnanda para ver cuanto hay del mismo tipo 
		SELECT a.producto,a.cantidad,b.detalle_producto,c.subGRUPO,d.tipo FROM detalle_comanda a,detalle_producto b,producto_menu c,subgrupo d;
		WHERE a.comanda=xqcomanda AND a.detalle AND A.ADICIONAL<>1 AND a.producto=b.detalle_producto AND b.producto=c.producto AND c.subgrupo=d.subgrupo UNION ALL;
		SELECT a.producto,a.cantidad,a.detalle_comanda ,c.subGRUPO,d.tipo FROM detalle_comanda a,producto_menu c,subgrupo d;
		WHERE a.comanda=xqcomanda AND !a.detalle AND A.ADICIONAL<>1 AND a.producto=c.producto AND c.subgrupo=d.subgrupo INTO CURSOR cdetalle_subg

		SELECT comensales FROM comanda WHERE comanda=xqcomanda INTO CURSOR ccomensales
		
		*** Esta suma la hago dependiendo de si lo hago por Tipo de Subgrupo o por producto
		IF (INLIST(Subgprodud.Tipo,3,6) .or. ElEvento.Vinos)
			LaCondicionSuma="producto=xqproducto"
		ELSE
			LaCondicionSuma="tipo=subgprodud.tipo"
		ENDIF
		
		SELECT SUM(cantidad) as cantidad FROM cdetalle_subg WHERE &LacondicionSuma INTO CURSOR misuma
		
		IF PrmCantidad=1
			IF subgprodud.TIPO<>5
				STORE "misuma.cantidad => (ccomensales.comensales*cdetevento.cantidad)" to xcondg
			ELSE
				STORE "misuma.cantidad => ccomensales.comensales*2" to xcondg
			endif			
			
			IF &xcondg
				store .t. TO xresp
			ELSE 	
				STORE .f. TO xresp
			ENDIF
		ELSE
		   	STORE .f. TO xresp
			* proyectar como va a quedar despues de insertarlo
			IF subgprodud.TIPO<>5
				STORE "misuma.cantidad+prmcantidad > (ccomensales.comensales*cdetevento.cantidad)" 	to xcondg
				STORE (ccomensales.comensales*cdetevento.cantidad) - misuma.cantidad 				to Loquefalta
				STORE prmcantidad-Loquefalta 															TO LoAdicional
			ELSE
				STORE "misuma.cantidad+prmcantidad > ccomensales.comensales*2" 			to xcondg
				STORE (ccomensales.comensales*2) - misuma.cantidad 						to Loquefalta
				STORE prmcantidad-Loquefalta 												TO LoAdicional
			ENDIF
			IF &xcondg
				* sobrepasa cuando inserte ==> partir las lineas
				   * 1. Verificar cuanto falta para llegar al limite (eso es una linea sin Adicional)
				   	LaNuevaCantidad=LoqueFalta
				   * 2. El resto que queda es otra linea con adicional
 				    STORE .t. TO DivideLaLinea
			ENDIF
		ENDIF
					
	ELSE  && No esta en el evento
		store .t. TO xresp
	*	DO FORM mesagebox WITH "Este producto no esta en el evento!"
	ENDIF
	
RETURN xresp