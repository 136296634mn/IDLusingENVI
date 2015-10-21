Pro get_regression_analysis

  compile_opt idl2

  envi, /restore_base_save_files
  envi_batch_init
  
  input_filename = dialog_pickfile(title='��ѡ����������')
  if (input_filename eq '') then return
  
  output_filename = dialog_pickfile(title='��ѡ���������', /write)
  if (output_filename eq '') then return
  
  ;��ȡ�����ļ���Ϣ������Ϊ�������򷵻�
  envi_open_file, input_filename, r_fid=input_fileid
  if (input_fileid eq -1) then return
  envi_file_query, input_fileid, ns=ns, nl=nl, nb=nb, dims=dims, $
                   data_type=data_type
  if (nb ne 1) then begin
    dialog_result = dialog_message(title='������Ϣ', ['��������Ϊ�ನ��', 'ģ�ͽ�Ӧ���ڵ�һ�����Σ�'], /information)
  endif
  
  ;������������Ľ���
  wbase = widget_auto_base(title='�ع�ģ�Ͳ�������')
    
    model_list = ['����ģ��:Y=0.81*b1+0.143', '������ģ��:Y=-0.43*b1^2+1.28*b1+0.05', $
                  '������ģ��:Y=-2.24*b1^3+3.29*b1^2-0.45*b1+0.23', '�ݺ���ģ��:Y=0.925*b1^0.694', $
                  'ָ��ģ��:Y=e^(b1-1.070)', 'Logisticģ��:Y=0.99+(0.21-0.99)/(1+(b1/0.53)^2.84)', $
                  '����ģ��:Y=alog(b1+1.294)']
    wslist = widget_slist(wbase, list=model_list, prompt='�ع�ģ���б�', select_prompt='ѡ���ģ��', uvalue='wslist', default=0, /auto)
    wstring = widget_string(wbase, uvalue='wstring', prompt='����ģ�ͱ��ʽ', $ 
                            default='0.81*b1+0.143', /auto)
  wresult = auto_wid_mng(wbase)  
  if (wresult.accept eq 0) then return
  exp = wresult.wstring
  
  envi_doit, 'math_doit', fid=input_fileid, pos=1, $
  dims=dims, out_bname='huigui', out_name=output_filename, $
  exp=exp 
  
  envi_batch_exit

End