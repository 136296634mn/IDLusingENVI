Pro logistic_fit, X, Y

  compile_opt idl2
  
  

End

;������ɢ�����ߵ�����
;Y=X(i), X0=0, X1=1, X2=2, ......
;���㷨Ĭ����ɢ��X����ļ��Ϊ1
Pro cal_curvature, Y, curvature

  compile_opt idl2
  
  ;size()����ֵΪ[ά��, ����, ��ά��Ԫ�ظ���, Ԫ���ܸ���]
  TypeX = size(Y)
  if (TypeX[0] ne 1) then begin
    message, '������һά����'
  endif
  
  ;����������ݵ�һ�Ͷ��׽׵���
  dy_1 = deriv(Y)
  dy_2 = deriv(dy_1)
  
  ;�����ɢ�������
  curvature = dy_2 / (1 + dy_1^2)^(3/2)
  
End


Pro get_max_curvature_position

  compile_opt idl2
  
  envi, /restore_base_save_files
  envi_batch_init
  
  input_file = dialog_pickfile(title='��ѡ�������ļ�')
  if (input_file eq '') then return
  
  output_file = dialog_pickfile(title='ѡ������ļ�', /write)
  if (output_file eq '') then return
  
  envi_open_file, input_file, r_fid=fid
  if (fid eq -1) then begin
    return_dialog = dialog_message(['���ļ�ʧ��: ', '���ļ��޷�ʹ��envi_open_file����'], title='������Ϣ', /information)
    return
  endif
  envi_file_query, fid, dims=dims, ns=ns, nl=nl, nb=nb, data_type=data_type
  
 ;����300M����зֿ鴦��
  file_size = ns*nl*nb*data_type_to_byte(data_type)
  max_file_size = 300*1024*1024
  
  if (file_size ge max_file_size) then begin
    
    print, '�ֿ鴦��'

    
  endif else begin
    
    print, '���崦��'

  
  endelse
  
  dialog_result = dialog_message(title='��ʾ��Ϣ', ['����������'], /information)
  
  ;envi_batch_exit  
  
End