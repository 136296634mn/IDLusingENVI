;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��[~_~];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; ��������
; MyShift
; ���÷�ʽ:
; MyShift(data, d)
; 
; Ŀ��:
; ƽ�������е�Ԫ�أ�ƽ�ƺ�ı߽�ֵ��0����
; �磺A=[1, 2, 3, 4, 5]����ƽ������Ԫ�أ��򷵻�[0, 0, 1, 2, 3]
;
; �������:
; data ����ƽ�Ƶ�����
; d    ƽ�ƾ��룬dΪ��ֵ������ƽ�Ʒ�֮����ƽ��
; 
; ��������ֵ:
; r_data ƽ�ƺ������
;
; ��ע��
;+
;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��[~_~];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function MyShift, data, d
;
  if d eq 0 then begin
    return, data
  endif

;d����0����ƽ�ƣ�dС��0����ƽ��
  if d gt 0 then begin
    for i=0l, n_elements(data)-1 do begin
      if i lt n_elements(data)-d then begin
        data[i] = data[i+d]
      endif else begin
        data[i] = 0
      endelse
    endfor
  endif else begin
    d=abs(d)
    for i=0l, n_elements(data)-1 do begin
      if i lt n_elements(data)-d then begin
        data[n_elements(data)-1-i] = data[n_elements(data)-1-i-d]
      endif else begin
        data[n_elements(data)-1-i] = 0
      endelse
    endfor
  endelse
  return, data
End