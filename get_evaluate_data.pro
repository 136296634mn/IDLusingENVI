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



;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��[~_~];;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; ��������
; PingJia(data1, data2, flag1, flag2)
;
; Ŀ�ģ�
; ����data2������data1���в�ֵ���ֵ���㼴��data2-data1
;
; ���������
; flag1:����ƥ�䷽ʽ(0�����ֵƥ�䡢1����Сֵƥ��)
; flag2:���۷�ʽ��(0:��ֵ����  ��    1����ֵ����)
; ����ֵ��
; ���� data2-data1  or  data2/data1
;
; ��ע��
;;;;;;;;;;;;;;;;;;;;;;;;lyh��ע��\~_~\;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Function PingJia, data1, data2, flag1, flag2
  ;
  COMPILE_OPT idl2
  ;�������Ƿ���ȷ
  ;dims = SIZE(data1)
  ;ȷ�����ֵ����Сֵλ��
  max_value1 = max(data1, max_subscript1, SUBSCRIPT_MIN=min_subscript1)
  max_value2 = max(data2, max_subscript2, SUBSCRIPT_MIN=min_subscript2)
  
  if flag1 eq 0 then begin
    move_distance = max_subscript2 - max_subscript1
  endif else begin
    move_distance = min_subscript2 - min_subscript1
  endelse 
  
  ;ƥ�䲢ƽ��data2
  data2 = myshift(data2, move_distance)
  
  outdata = make_array(n_elements(data1))
  ;ȥ��ͷβֻ���۹��еĲ�������,ͷβ����ֵΪ100
  ;data2��data1��ֵ���ֵ����
  if (flag2 eq 0) then begin 
    ;outdata = data2 - data1
    for i=0, n_elements(data1)-1 do begin
      if data2[i] eq 0 then begin
        outdata[i] = -100
      endif else begin
        outdata[i] = data2[i] - data1[i]
      endelse
    endfor
          
  endif else begin
    ;��ֵ�Ƚ�
    for i=0, n_elements(data1)-1 do begin
      if (data2[i] eq 0) or (data1[i] eq 0) then begin
        outdata[i] = -100
      endif else begin
        outdata[i] = data2[i] / data1[i] 
      endelse      
    endfor
    
  endelse
  
  return, outdata
  
End


Pro get_evaluate_data

  compile_opt idl2
  
  envi, /restore_base_save_files
  envi_batch_init
  
  input_filename_1 = ENVI_PICKFILE(TITLE='���������ƽ������')
  if n_elements(input_filename_1) eq 0 then return  
  
  input_filename_2 = envi_pickfile(title='���������������')
  if n_elements(input_filename_2) eq 0 then return
  
  output_filename = envi_pickfile(title='����ļ���' ,/output)
  if (output_filename eq '') then return
  
  wbase = widget_auto_base(title='ѡ������ƥ�䷽ʽ')
    wtoggle_1 = widget_toggle(wbase, list=['���ֵƥ��', '��Сֵƥ��'], prompt='ѡ��ƥ�䷽ʽ:', $
    uvalue='mtoggle_1', /auto)
    
    wtoggle_2 = widget_toggle(wbase, list=['��ֵ����', '��ֵ����'], prompt='ѡ��ƥ�䷽ʽ:', $
    uvalue='mtoggle_2', /auto)
    
  mresult = auto_wid_mng(wbase)
  if (mresult.accept eq 0) then return  
  pipei_flag = mresult.mtoggle_1
  pingjia_flag = mresult.mtoggle_2
  
  envi_open_file, input_filename_1, r_fid=input_fileid_1
  envi_open_file, input_filename_2, r_fid=input_fileid_2
  if ((input_fileid_1 eq -1) or (input_fileid_2 eq -1)) then return
  
  envi_file_query, input_fileid_1, dims=dims, $
  ns=ns, $
  nl=nl, $
  nb=nb, $
  data_type=data_type, $
  interleave=interleave
  
  ;������ļ�
  openw, output_file_unit, output_filename, /get_lun
  
  ;�ֿ鴦������
  tile_nums = 10
  tile_lines = [nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl/tile_nums, $
                nl/tile_nums, nl-nl/tile_nums*9]
                
  ;ѭ������Tiles������
  for i=0l, tile_nums-1 do begin
    ;ƽ������
    input_data_1 = make_array(ns, tile_lines[i], $
    nb)
    ;����������
    input_data_2 = make_array(ns, tile_lines[i], $
    nb)
    ;output_data�����������
    output_data = make_array(ns, tile_lines[i], $
    nb)
    for j=0l, nb-1 do begin
      input_data_1[*, *, j] = envi_get_data(fid=input_fileid_1, $
      dims = [dims[0], $
              dims[1], $
              dims[2], $
              i*nl/tile_nums, $
              i*nl/tile_nums + tile_lines[i]-1], $
      pos = j )
      input_data_2[*, *, j] = envi_get_data(fid=input_fileid_2, $
      dims = [dims[0], $
              dims[1], $
              dims[2], $
              i*nl/tile_nums, $
              i*nl/tile_nums + tile_lines[i]-1], $
      pos = j )      
    endfor

    ;�����ݽ�������, ƽ��ƽ������, ���������ݹ̶�
    for m=0l, ns-1 do begin
      for n=0l, tile_lines[i]-1 do begin
        output_data[m, n, *] = pingjia(input_data_2[m, n, *], input_data_1[m, n, *], $
                                     pipei_flag, pingjia_flag)
      endfor
    endfor
  
    ;�����ݴ洢��ʽת��ΪBIL����д������ļ���
    output_data = transpose(temporary(output_data), [0, 2, 1])
    writeu, output_file_unit, output_data
    
    print, '��', i, '��'
  
  endfor
  
  ;�ر��ļ�
  free_lun, output_file_unit
  
  ;data_type:float
  map_info = envi_get_map_info(fid=input_fileid_1)
  envi_setup_head, fname=output_filename, ns=ns, nl=nl, nb=nb, map_info=map_info, $ 
  data_type=4, offset=0, interleave=1, $
  descrip='Test routine output', /write, /open
    
  envi_batch_exit

End