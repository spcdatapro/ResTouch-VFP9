SELECT A.FECHA,A.COMANDA,B.NOMBRES,IIF(A.STATUS=5,"X"," ") AS COBRADO, ;
SUM(C.SUBTOTAL) AS SUBTOTALD,D.FACTURA,D.SUBTOTAL,D.DESCUENTO,D.TOTAL;
FROM COMANDA A, EMPLEADO B, DETALLE_COMANDA C, FACTURA D;
 WHERE A.MESERO=B.EMPLEADO;
 AND A.COMANDA=C.COMANDA AND C.ENVIADO AND A.COMANDA=D.COMANDA;
 AND !D.ANULADA;
 GROUP BY C.COMANDA;
ORDER BY A.COMANDA
