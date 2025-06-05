    
   ---------1.VIEW----------------
---------------------------------------------------------------------------------------------------
--- 1.1 Tao view  vw_NhapHang de xem thong tin phieu nhap hang, ngay nhap hang, so loai hang hoa nhap va tong so luong hang hoa nhap
    
    CREATE OR REPLACE VIEW vw_NhapHang AS
    SELECT nh.MaNhapHang,NgayNhapHang, NVL(COUNT(CT.MaSP),0) AS SoLoaiHangHoa,
            NVL(sum(SoLuong),0) as TongSoLuongNhap
    FROM  NhapHang nh left join CTNhapHang ct on nh.MaNhapHang = ct.MaNhapHang
    group by nh.MaNhapHang,NgayNhapHang
    order by nh.MaNhapHang;
    
    -- Kiem thu
    select * from vw_NhapHang;
    
--4.2.Thong ke doanh so ban hang tung nhan vien theo tung thang trong nam 2023
    create or replace view vw_2023_DoanhSo
    as
    SELECT NhanVien.MANV, HOTEN ,EXTRACT(MONTH FROM NGAYLAP) AS THANG,
    EXTRACT(YEAR FROM NGAYLAP) AS NAM, SUM(DONGIA*SOLUONGSP) AS TONG_DOANH_SO
    FROM (NhanVien join HoaDon on NhanVien.MANV = HoaDon.MANV)
        join CTHoaDon on CTHoaDon.MAHOADON=HOADON.MAHOADON     
    WHERE EXTRACT(YEAR FROM NGAYLAP) = 2023
    GROUP BY EXTRACT(MONTH FROM NGAYLAP), NhanVien.MANV, HOTEN,EXTRACT(YEAR FROM NGAYLAP)
    order by THANG;
    
    select* from vw_2023_DoanhSo;
    
   --4.3. Cho biet san pham ban chay nhat trong nam 2023
    create or replace view vw_2023_BestSeller
    as
    select  SanPham.MASP, TENSANPHAM, sum(SOLUONGSP) as SO_LUONG_BAN
    from (SanPham join CTHOADON on SanPham.MASP = CTHOADON.MASP)
         join HOADON on HOADON.MAHOADON=CTHOADON.MAHOADON 
    where EXTRACT(YEAR FROM NGAYLAP) = '2023'
    group by SanPham.MASP,TENSANPHAM
    having sum(SOLUONGSP) >= all 
    (
        select sum(SOLUONGSP)
        from (SanPham join CTHOADON on SanPham.MASP = CTHOADON.MASP)
         join HOADON on HOADON.MAHOADON=CTHOADON.MAHOADON 
        where EXTRACT(YEAR FROM NGAYLAP) = '2023'
        group by SanPham.MASP
    );
    
    select* from vw_2023_BestSeller;
    
    --4.4. Thong ke san pham theo thang trong nam 2022----------------
    --------------------------------------------------------------------------------------
    create or replace view vw_Month_product
    as
     select SanPham.MASP, TENSANPHAM, EXTRACT(MONTH FROM NGAYLAP) 
            as Thang , sum(SOLUONGSP) as SO_LUONG_BAN
    from (SanPham join CTHOADON on SanPham.MASP = CTHOADON.MASP)
         join HOADON on HOADON.MAHOADON=CTHOADON.MAHOADON 
    where EXTRACT(YEAR FROM NGAYLAP) = 2022
    group by SanPham.MASP, TENSANPHAM,EXTRACT(MONTH FROM NGAYLAP)
    order by Thang;
    
  select* from vw_Month_product;
  
    --4.5. Liet ke phong ban khong co nhan vien
    create or replace view vw_NotExit_Emp
    as
    select TenBP, MABP
    from BOPHAN dept 
    where 
    not exists (select null from NHANVIEN emp  
    where emp.MABP= dept.MABP);
        
      select* from vw_NotExit_Emp;
      
      
    --4.6. Tao view tim kiem thong tin Nhan vien xu ly hoa don
    --theo ten khach hang mua
    create or replace view vw_Infor_Emp_cust
    as
    select *
    from NHANVIEN
    where MANV
    in
    (select MANV
    from HOADON join KHACHHANG ON HOADON.MAKH=KHACHHANG.MAKH
    where HOTENKH='Vu Duc Huy');
    
    
    select* from vw_Infor_Emp_cust;
    
    
    --4.7.Nhan vien co doanh so ban hang thap nhat trong nam 2023
    create or replace view vw_nv_dsThap_2023
    as
    select NhanVien.MANV, HOTEN, sum (SOLUONGSP*DONGIA)as Doanh_So
    from (NhanVien join HoaDon on NhanVien.MANV = HoaDon.MANV)join CTHoaDon 
    on CTHoaDon.MAHOADON=HOADON.MAHOADON  
    where EXTRACT(YEAR FROM NGAYLAP) = '2023'
    group by NhanVien.MANV, HOTEN
    having sum (SOLUONGSP*DONGIA) <= all
    (
        select sum (SOLUONGSP*DONGIA)
        from (NhanVien join HoaDon on NhanVien.MANV = HoaDon.MANV)join CTHoaDon 
    on CTHoaDon.MAHOADON=HOADON.MAHOADON  
        where EXTRACT(YEAR FROM NGAYLAP) = '2023'
        group by NhanVien.MANV, HOTEN
    );
    
    
    select* from vw_nv_dsThap_2023;
    
--4.8. In ra danh sach san pham (MASP,TENSP) cua nha cung cap ?Noi that Moc Viet? hoac
--?Noi that Truc Linh? co gia tu 500.000 den 2.000.000.
    create or replace view vw_Infor_pduct_supplier
    as
    SELECT SANPHAM.MASP, TENSANPHAM, TENNCC, GIABAN
    FROM ((CTNHAPHANG JOIN SANPHAM ON CTNHAPHANG.MASP=SANPHAM.MASP)
        join NHAPHANG ON CTNHAPHANG.MANHAPHANG=NHAPHANG.MANHAPHANG)
        JOIN NHACUNGCAP ON NHAPHANG.MANCC=NHACUNGCAP.MANCC
    WHERE (TENNCC = 'Noi that Moc Viet' OR TENNCC = 'Noi that Truc Linh')
    AND GIABAN BETWEEN 500000 AND 2000000;
    
    
    select* from vw_Infor_pduct_supplier;
    
    
    
   ---------2. PROCEDURE----------------
---------------------------------------------------------------------------------------------------
--2.1.Viet tham so dau vao la thang, nam lap hoa don, thu tuc in ra thong tin don hang duoc mua trong thang nam do
-- Thong tin gom: MAHOADON,NGAYLAP, TONGGIATRI
----> thieu exception khi thong tin nhap khong ton tai.....          
    create or replace procedure pr_Bill_mon_yer (p_month NVARCHAR2,p_year nvarchar2)
    as
    v_year number;
    v_month number;
    cursor c_ord is 
    select MAHOADON,NGAYLAP, TONGGIATRI
    from HOADON
        where EXTRACT(YEAR FROM NGAYLAP)= v_year 
        and EXTRACT(MONTH FROM NGAYLAP) = v_month;
    soHD  HOADON.MAHOADON%type;
    ngayTao  HOADON.NGAYLAP%type;
    tongTienHD  HOADON.TONGGIATRI%type;
    begin
         ---exception gia tri nhap null
        IF p_month IS NULL OR p_year IS NULL THEN
            RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap day du thong tin');
        END IF;
       ---Gia tri nhap vao khong phai so
        IF NOT REGEXP_LIKE(p_year,'^[0-9]+$') OR NOT REGEXP_LIKE(p_month,'^[0-9]+$')then
            RAISE_APPLICATION_ERROR(-20020,'Vui long nhap dung dinh dang so');
        else
        v_year:=to_number(p_year);
        v_month:=to_number(p_month);
        end if;
        
    open c_ord;
    loop
            fetch c_ord into soHD,ngayTao,tongTienHD;
            exit when c_ord%notfound;
            DBMS_OUTPUT.put_line('----------------');
            DBMS_OUTPUT.put_line(' STT: ' || c_ord%rowcount);
            DBMS_OUTPUT.put_line(' So don hang: ' || soHD);
            DBMS_OUTPUT.put_line('Ngay dat don: '|| ngayTao);
            DBMS_OUTPUT.put_line(' Tong tien hoa don: ' || tongTienHD);
            
    end loop;
    close c_ord;
    end pr_Bill_mon_yer;
    
    
    
    --Calling    
    ================= 
    SET SERVEROUTPUT ON;
    declare 
    p_month nvarchar2(10) :='&MONTH';
    p_year nvarchar2(10) := '&YEAR';
    begin
    pr_Bill_mon_yer(p_month,  p_year);
    end;

--2.2.In danh sach nhan vien co muc luong lon hon  n. Voi n là tham so dau vao. 
--Danh sach gom: MANV, HOTEN, LUONG*/
 
    create or replace procedure pr_nhanviencoluonglonhon_n (n nvarchar2)
    as 
        n_temp number;
        cursor c_nv is 
            select MANV, HOTEN, LUONG
            from NHANVIEN
            where LUONG > n_temp;   
        id NHANVIEN.MANV %type;
        name NHANVIEN.HOTEN%type;
        salary NHANVIEN.LUONG %type;
    begin
     ---exception gia tri nhap null
        IF n IS NULL THEN
            RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap day du thong tin');
        END IF;
       ---Gia tri nhap vao khong phai so
        IF NOT REGEXP_LIKE(n,'^[0-9]+$')then
            RAISE_APPLICATION_ERROR(-20020,'Vui long nhap dung dinh dang so');
        else
            n_temp:=to_number(n);
        end if;
    DBMS_OUTPUT.put_line( ' DANH SACH NHAN VIEN CO MUC LUONG LON HON ' || n);
        open c_nv ;
        loop
            fetch c_nv  into id, name, salary;
            exit when c_nv %notfound;
            DBMS_OUTPUT.put_line('----------------');
            DBMS_OUTPUT.put_line(' STT: ' || c_nv %rowcount);
            DBMS_OUTPUT.put_line(' Ma nhan vien: ' || id);
            DBMS_OUTPUT.put_line(' Ho va ten: ' || name);
            DBMS_OUTPUT.put_line(' Muc luong: '|| salary);
        end loop;
        close c_nv ;
    end pr_nhanviencoluonglonhon_n;
 
 
    
    --Calling    
    ==================
    SET SERVEROUTPUT ON;
    declare 
    n nvarchar2(100) :='&NHAPMUCLUONG';
    begin
    pr_nhanviencoluonglonhon_n(n);
    end;

--2.3. Tao procedure tinh luong trung binh cua nhan vien o moi phong ban, dau vao la MABP. 
--In ra chi tiet: TENBP, MOTA, MABP, Luong trung binh 
    CREATE OR REPLACE PROCEDURE pr_calculate_avg_salary(p_department_id int) AS
             v_total_salary NUMBER := 0;
             v_employee_count NUMBER := 0;
             v_avg_salary NUMBER;
            cursor c_bophan is
            select TENBP, MOTA from BOPHAN
            where MABP=p_department_id; 
             p_name_depart BOPHAN.TENBP%TYPE;
             P_des BOPHAN.MOTA%TYPE;
            BEGIN
            FOR emp IN (SELECT LUONG FROM NHANVIEN WHERE MABP = p_department_id) 
            LOOP
            v_total_salary := v_total_salary + emp.LUONG;
            v_employee_count := v_employee_count + 1;
            END LOOP;
            open c_bophan ;
            loop
            fetch c_bophan into p_name_depart, P_des;
            exit when c_bophan%notfound;
            
                DBMS_OUTPUT.put_line('-----DEPARTMENT INFORMATION-----');
                DBMS_OUTPUT.put_line('  Department id: ' || p_department_id);
                DBMS_OUTPUT.put_line('  Department name: ' || p_name_depart);
                DBMS_OUTPUT.put_line('  Description: ' || P_des);
                DBMS_OUTPUT.put_line('--------------------------------');
            end loop;
            IF v_employee_count> 0 THEN
            v_avg_salary := v_total_salary / v_employee_count;
                DBMS_OUTPUT.PUT_LINE('Average Salary for Department ' || 
                p_department_id || ': ' || v_avg_salary);
            ELSE
                DBMS_OUTPUT.PUT_LINE('No employees found in Department ' 
                || p_department_id);
            END IF;
            EXCEPTION
            WHEN OTHERS THEN
                DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);    
            END pr_calculate_avg_salary;
            /
          
    --Calling    
    ================ 
    ---------
    SET SERVEROUTPUT ON;
    declare
    p_department_id int; 
    BEGIN
    p_department_id:=&MABP;
    pr_calculate_avg_salary( p_department_id);
    END;
    /
    
--2.4 nhap vao ma nhom in ra danh sach san pham ban duoc trong nhom hang do

        create or replace procedure pr_epduct_group (p_gr SANPHAM.MANHOM%TYPE)
            as
            v_count_sp int;
            cursor c_pduct is 
                select SANPHAM.MASP, TENSANPHAM, sum(SoLuongSP), GIABAN
                from SANPHAM JOIN CTHOADON ON SANPHAM.MASP=CTHOADON.MASP
                WHERE MANHOM = p_gr
                group by SANPHAM.MASP, TENSANPHAM,GIABAN;
                
                v_masp SANPHAM.MASP%TYPE;
                v_tensp SANPHAM.TENSANPHAM%type;
                v_soluong CTHOADON.SOLUONGSP%type;
                v_giaban SANPHAM.GIABAN%type;
            begin
            ---exception ma nhom khong ton tai trong bang san pham
            select count(*)into v_count_sp
            from SANPHAM
            where MANHOM = p_gr ;
            IF v_count_sp=0 THEN
            DBMS_OUTPUT.PUT_LINE('error: Khong ton tai ma nhom: '||p_gr);
            ELSE  
            open c_pduct;
            loop
        fetch c_pduct into  v_masp, v_tensp, v_soluong, v_giaban;
        exit when c_pduct%notfound;
        DBMS_OUTPUT.put_line('------------------------------------');
        DBMS_OUTPUT.put_line(' STT: ' || c_pduct%rowcount);
        DBMS_OUTPUT.put_line(' Ma san pham: ' ||  v_masp);
        DBMS_OUTPUT.put_line(' Ten san pham: '|| v_tensp);
        DBMS_OUTPUT.put_line(' So luong da ban: '|| v_soluong);
        DBMS_OUTPUT.put_line(' Gia ban: '|| v_giaban);  
        DBMS_OUTPUT.put_line('------------------------------------');
            end loop;   
            close c_pduct;
            END IF;
            end pr_epduct_group; 
            
    --Calling    
    ================ 
    ---------
    SET SERVEROUTPUT ON;
    declare
    p_gr SANPHAM.MANHOM%TYPE; 
    BEGIN
     p_gr:='&MANHOM';
    pr_epduct_group( p_gr);
    END;
    /
    
--2.5.THEM chat lieu
     create or replace PROCEDURE pr_add_material
     (v_macl CHATLIEU.MACHATLIEU%TYPE,
      v_tencl CHATLIEU.TENCHATLIEU%TYPE)
      as
      v_macl_temp CHATLIEU.MACHATLIEU%TYPE;
      v_error EXCEPTION;
      begin
      select MACHATLIEU INTO v_macl_temp
      from CHATLIEU
      where MACHATLIEU = v_macl;
      if  v_macl_temp is not null then
      raise  v_error;
      end if;
      --exception xu ly loi trung lap
      exception when  v_error then
        DBMS_OUTPUT.PUT_LINE('error: Khong the them du lieu do trung lap ma: '||v_macl);
        when no_data_found then
        insert into CHATLIEU(MACHATLIEU, TENCHATLIEU) VALUES (v_macl, v_tencl);
        DBMS_OUTPUT.PUT_LINE('Chat lieu '||v_tencl||' voi ID: '||v_macl||' Da duoc them');
        end;
      
      
    --Calling    

    SET SERVEROUTPUT ON;
    declare
    v_macl CHATLIEU.MACHATLIEU%TYPE;
    v_tencl CHATLIEU.TENCHATLIEU%TYPE; 
    BEGIN
    v_macl:=&MACHATLIEU;
    v_tencl:=&TENCHATLIEU;
    pr_add_material( v_macl, v_tencl);
    END;
    /      



 ---------3.FUNCTION--------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
/* 3.1. Tao Function co ten f_SoLuongSP_TheoChatLieu 
Tinh so luong san pham trong kho co Ma chat lieu la tham so truyen vao"*/
  CREATE OR REPLACE FUNCTION f_SoLuongSP_TheoChatLieu (i_maCL IN ChatLieu.MaChatLieu%type)
    RETURN NUMBER
    IS
        v_TongSanPham NUMBER;
        v_ChatLieuExists NUMBER;
    BEGIN 

        --------------- Kiem tra thong tin nhap vao------------------------
        IF i_maCL  IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20020,'Ma chat lieu khong duoc de trong');
        END IF;
    
        -- Kiem tra su ton tai cua Ma chat lieu
        SELECT COUNT(*) INTO v_ChatLieuExists
        FROM ChatLieu
        WHERE MaChatLieu = i_maCL ;
    
        IF v_ChatLieuExists = 0 THEN
            RAISE_APPLICATION_ERROR(-20020,'Chat lieu voi ma ' || i_maCL  || ' khong ton tai');
        END IF;
        --------------- Noi dung function------------------------
         -- Tinh tong san pham lam bang chat lieu i_maCL
            SELECT SUM(SoLuongTon) INTO v_TongSanPham
            FROM SanPham
            WHERE MaChatLieu = i_maCL;
        
        RETURN v_TongSanPham;
    END;
    
        
        
--------------------------------------------
 --------CALL FUNCTION----------------------
--- Kiem thu
        SET SERVEROUTPUT ON;
        DECLARE
            macl ChatLieu.MaChatLieu%type := '&NhapMaChatLieu';
        BEGIN
           DBMS_OUTPUT.PUT_LINE('Mat hang co ma chat lieu ' || macl|| ' con: ' ||  f_SoLuongSP_TheoChatLieu(macl) || 'sp trong kho');
        END;



/* 3.2. Tao Function co ten f_SoLuongNhap_NCC voi i_maNCC - Ma nha cung cap va i_year - nam nhap hang
la tham so truyen vao, ket qua tra ve la thong bao "Nam i_year da nhap cua nha cung cap i_maNCC
tong so ... san pham trong do co ....loai san pham"*/

    CREATE OR REPLACE FUNCTION f_SoLuongNhap_NCC (
        i_maNCC IN NhaCungCap.MaNCC%type,
        i_year IN nvarchar2 
    )
    RETURN nvarchar2
    IS
        v_TongSoLuongNhap NUMBER := 0;
        v_TongSoLoaiNhap NUMBER := 0;
        v_NhaCungCapExists number;
        v_messager nvarchar2(2000);
        v_YearNumber NUMBER; -- Bien de chua gia tri so cua i_year
    
    BEGIN 
    --------------- Kiem tra thong tin nhap vao------------------------
        -- Gia tri nhap vao null
        IF i_maNCC IS NULL OR i_year IS NULL THEN
            RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap day du thong tin');
        END IF;
    
        -- Kiem tra su ton tai cua i_maNCC
        SELECT COUNT(*) INTO v_NhaCungCapExists
        FROM NhaCungCap
        WHERE MaNCC = i_maNCC;
    
        IF v_NhaCungCapExists = 0 THEN
            RAISE_APPLICATION_ERROR(-20020, 'Nha cung cap voi ma ' || i_maNCC || ' khong ton tai');
        END IF;
        
         ---Gia tri nhap vao khong phai la so
        IF NOT REGEXP_LIKE (i_year, '^[0-9]+$') THEN
            RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap dung dinh dang nam');
        ELSE 
            v_YearNumber := to_number(i_year);
        END IF;
        
     -------- Noi dung function---------
            IF v_YearNumber IS NOT NULL THEN
                SELECT NVL(SUM(SoLuong), 0), COUNT(DISTINCT MaSP)
                INTO v_TongSoLuongNhap, v_TongSoLoaiNhap 
                FROM CTNhapHang ct 
                JOIN NhapHang nh ON ct.MaNhapHang = nh.MaNhapHang
                WHERE MaNCC = i_maNCC AND EXTRACT(YEAR FROM NGAYNHAPHANG) = v_YearNumber;
                
                v_messager := 'Nam ' || v_YearNumber || ' da nhap cua nha cung cap ' || i_maNCC ||
                               ' tong so ' || v_TongSoLuongNhap || ' san pham trong do co ' ||
                               v_TongSoLoaiNhap || ' loai san pham';
            END IF;
        RETURN  v_messager;
    END;



--------------------------------------------
--------CALL FUNCTION----------------------
--- Kiem thu
    SET SERVEROUTPUT ON;
    exec DBMS_OUTPUT.PUT_LINE('' || f_SoLuongNhap_NCC ('&NhapMaNCC','&NhapNamNhap'));




/* 3.3. Tao Function co ten f_TongTienTichLuy_KhachHang tinh tong tien ma khach hang tich luy duoc 
khi mua hoa don voi MaKH la tham so truyen vao*/

    CREATE OR REPLACE FUNCTION f_TongTienTichLuy_KhachHang (i_makh IN KhachHang.MaKH%type)
    RETURN NUMBER
    IS
        v_TongTienTichLuy NUMBER := 0;
        v_KhachHangExists NUMBER;
    BEGIN 
        --------------- Kiem tra thong tin nhap vao------------------------
        IF i_makh IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20020,'Ma khach hang khong duoc de trong');
        END IF;
    
        -- Kiem tra su ton tai cua Ma khach hang
        SELECT COUNT(*) INTO v_KhachHangExists
        FROM KhachHang
        WHERE MaKH = i_makh;
    
        IF v_KhachHangExists = 0 THEN
            RAISE_APPLICATION_ERROR(-20020,'Khach hang voi ma ' || i_makh || ' khong ton tai');
        END IF;
        --------------- Noi dung function------------------------
        BEGIN
                -- Tinh tong tien tich luy
                SELECT NVL(SUM(ct.SoLuongSP * ct.DonGia), 0) INTO v_TongTienTichLuy
                FROM HoaDon hd JOIN CTHoaDon ct ON hd.MaHoaDon = ct.MaHoaDon
                WHERE hd.MaKH = i_makh;
        END;
    
        RETURN v_TongTienTichLuy;
    END f_TongTienTichLuy_KhachHang;
    
    
         
         
 --------------------------------------------
--------CALL FUNCTION----------------------
--- Kiem thu
        SET SERVEROUTPUT ON;
        DECLARE
            makh KhachHang.MaKH%type := '&NhapMaKH';
        BEGIN
            DBMS_OUTPUT.PUT_LINE('Khach hang ' || makh || ' da tich luy duoc tong so tien la: ' || f_TongTienTichLuy_KhachHang(makh));
        END;
    
    
    
    
/* 3.4*  Tao Function co ten f_XepLoaiSP_TheoNhom de xep loai San pham theo Nhom san pham dua vao so luong 
san pham da ban duoc. Trong do NhomSP la tham so dau vao
    Tieu chi xep loai: Tong so luong ban ra >= 25 ==> Hang ban chay loai 1
                       Tong so luong ban ra < 25  va >= 10 ==> Hang ban chay loai 2
                       Tong so luong ban ra < 10  va >= 1 ==> Hang ban e
                       Tong so luong ban ra =0 ==> Hang khong ban duoc*/
                       
    create or replace FUNCTION f_XepLoaiSP_TheoNhom ( i_nhomSP IN Nhom.MaNhom%type)
    RETURN SYS_REFCURSOR
    as
        c_xeploaiSP  SYS_REFCURSOR;
        v_NhomspExists number;
    BEGIN 
        --------------- Kiem tra thong tin nhap vao------------------------
        IF i_nhomSP IS NULL THEN 
            RAISE_APPLICATION_ERROR(-20020,'Ma nhom san pham khong duoc de trong');
        END IF;
    
        -- Kiem tra su ton tai cua Ma nhom san pham
        SELECT COUNT(*) INTO v_NhomspExists 
        FROM Nhom
        WHERE MaNhom = i_nhomSP;
    
        IF v_NhomspExists = 0 THEN
            RAISE_APPLICATION_ERROR(-20020,'Nhom san pham voi ma ' || i_nhomSP || ' khong ton tai');
        END IF;
        
        --------------- Noi dung function------------------------
        BEGIN
            OPEN c_xeploaiSP FOR
                select sp.MaSP, TenSanPham, NVL(sum(SoLuongSP),0) as SoLuongDaBan,
                   CASE
                    WHEN NVL(sum(SoLuongSP),0) >= 25 THEN 'Hang ban chay loai 1'
                    WHEN NVL(sum(SoLuongSP),0) >= 10 AND NVL(sum(SoLuongSP),0) < 25 THEN 'Hang ban chay loai 2'
                    WHEN NVL(sum(SoLuongSP),0) >=1 AND NVL(sum(SoLuongSP),0) < 10  THEN 'Hang ban e'
                    WHEN NVL(sum(SoLuongSP),0) = 0 then  'Hang khong ban duoc'
                     END AS XepLoaiSanPham
                from (Nhom n left join SanPham sp on n.MaNhom = sp.MaNhom)
                     left join CTHoaDon ct on sp.MaSP = ct.MaSP
                where n.MaNhom = i_nhomSP
                group by sp.MaSP, TenSanPham
                order by XepLoaiSanPham;
        END;
        return c_xeploaiSP;
    END ;
    
    
 
--------------------------------------------
--------CALL FUNCTION----------------------  
----Kiem thu
    SET SERVEROUTPUT ON;
    declare 
        c_xeploaiSP SYS_REFCURSOR;
        v_nhomsp SanPham.MaNhom%type;
        v_masp SanPham.MaSP%type;
        v_tensp SanPham.TenSanPham%type;
        v_tongsoluongbanra number;
        v_xeploai nvarchar2(2000);
    BEGIN
        v_nhomsp := '&NhapMaNhom';

        c_xeploaiSP :=  f_XepLoaiSP_TheoNhom  (v_nhomsp);
        DBMS_OUTPUT.PUT_LINE('---------XEP LOAI SAN PHAM NHOM '|| v_nhomsp || '-------------------------' );
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------------');
        
        LOOP
        fetch c_xeploaiSP into v_masp,v_tensp,v_tongsoluongbanra,v_xeploai;
        exit when c_xeploaiSP%notfound;
        DBMS_OUTPUT.PUT_LINE('SanPham: '|| v_masp ||'. '|| v_tensp );
        DBMS_OUTPUT.PUT_LINE('Da ban duoc: '|| v_tongsoluongbanra );
        DBMS_OUTPUT.PUT_LINE('===> Xep loai: ' || v_xeploai); 
        DBMS_OUTPUT.PUT_LINE('----------------');
        end loop;
        close c_xeploaiSP;
    END;
    
    
    
/* 3.5. Tao function f_VoucherCuoiNam_KhachHang voi tham so dau vao la i_nam (Nam),tinh voucher giam gia cuoi nam
cho tung khach hang dua theo Tong tien khachh hang tich mua duoc khi mua hoa don trong nam do dua theo
    Tieu chi:
       TongTienTichLuy >= 20.000.000  thi Voucher = 10% TongTienTichLuy
       TongTienTichLuy < 20.000.000 va >= 10.000.000  thi Voucher = 8% TongTienTichLuy
       Duoi 10.000.000 thì Voucher = 7% TongTienTichLuy
    D?a vao function f_TongTienTichLuy_KhachHang(MaKH) de tinh tong tien tich luy cua khach hang*/

create or replace FUNCTION f_VoucherCuoiNam_KhachHang ( i_year IN nvarchar2 )
    RETURN SYS_REFCURSOR
    as
        c_voucher_KhachHang  SYS_REFCURSOR;
        v_YearNumber NUMBER;-- Bien de chua gia tri so cua i_year
    BEGIN 
     --------------- Kiem tra thong tin nhap vao------------------------
        --- Gia tri nhap vao null
        IF i_year IS NULL THEN
            RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap day du thong tin');
        END IF;
        ---Gia tri nhap vao khong phai la so
        IF NOT REGEXP_LIKE (i_year, '^[0-9]+$') THEN
            RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap dung dinh dang');
        ELSE 
            v_YearNumber := to_number(i_year);
        END IF;
        
    --------------- Noi dung function------------------------
         OPEN c_voucher_KhachHang FOR
        SELECT MaKH, HoTenKH, TongTienTichLuy,
           CASE 
           WHEN TongTienTichLuy >= 20000000 THEN 0.1*TongTienTichLuy
           WHEN TongTienTichLuy < 20000000 and TongTienTichLuy >= 10000000 THEN 0.08*TongTienTichLuy
           ELSE 0.07* TongTienTichLuy END AS Voucher
        from (
            SELECT kh.MaKH, HoTenKH, CASE 
                WHEN EXTRACT(YEAR FROM NGAYLAP) = v_YearNumber THEN f_TongTienTichLuy_KhachHang(kh.MaKH)
                ELSE 0 END AS TongTienTichLuy
            FROM KHACHHANG kh LEFT JOIN HoaDon hd ON kh.MaKH = hd.MaKH
            order by kh.MaKH
              ) ;
         RETURN  c_voucher_KhachHang;
    END;
        
    
  
--------------------------------------------
--------CALL FUNCTION----------------------
 ----Kiem thu
    SET SERVEROUTPUT ON;
    declare 
        c_voucher_KhachHang SYS_REFCURSOR;
        v_makh KhachHang.MaKH %type;
        v_tenkh KhachHang.HoTenKH%type;
        v_tongtientichluy number;
        v_voucher number;
        v_nam nvarchar2(2000);
    BEGIN
        v_nam := '&NhapNam';

        c_voucher_KhachHang :=  f_VoucherCuoiNam_KhachHang  (v_nam);
        DBMS_OUTPUT.PUT_LINE('----DANH SACH AP DUNG VOUCHER KHACH HANG NAM '|| v_nam || '------------' );
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------');
        
        LOOP
        fetch c_voucher_KhachHang into v_makh,v_tenkh,v_tongtientichluy,v_voucher;
        exit when c_voucher_KhachHang%notfound;
        DBMS_OUTPUT.PUT_LINE('Khach Hang: '|| v_makh ||'. '|| v_tenkh );
        DBMS_OUTPUT.PUT_LINE('Tong tien tich luy: '|| v_tongtientichluy||'==> Voucher: ' || v_voucher );
        DBMS_OUTPUT.PUT_LINE('----------------');
        end loop;
        close c_voucher_KhachHang;
    END;
    
    

--------------------------------------------------------------
------------4.PACKAGE
--------------------------------------------------------------

--4.1.Tao package pk_sup_package gom 3 thu tuc: them, xoa, in thong tin nha cung cap

------------TAO PACKAGE--------------
    CREATE OR REPLACE PACKAGE pk_sup_package AS 
    --Thu tuc them thong tin nha cung cap
    PROCEDURE addSupplier(
    s_id   NHACUNGCAP.MANCC%type, 
    s_name NHACUNGCAP.TENNCC%type, 
    s_addr NHACUNGCAP.DIACHINCC%type,  
    s_phone  NHACUNGCAP.DIENTHOAINCC%type, 
    s_fax  NHACUNGCAP.FAXNCC%type,
    s_email NHACUNGCAP.EMAILNCC%type); 
    --Thu tuc xoa thong tin nha cung cap 
    PROCEDURE delSupplier( s_id   NHACUNGCAP.MANCC%type); 
    --Thu in danh sach nha cung cap
    PROCEDURE listSupplier; 
    END pk_sup_package; 
    /  
    
    
------------TAO PACKAGE BODY--------------
        CREATE OR REPLACE PACKAGE BODY pk_sup_package AS 
        -- Thu tuc them thong tin nha cung cap
    PROCEDURE addSupplier( 
        s_id   NHACUNGCAP.MANCC%type, 
        s_name NHACUNGCAP.TENNCC%type, 
        s_addr NHACUNGCAP.DIACHINCC%type,  
        s_phone  NHACUNGCAP.DIENTHOAINCC%type, 
        s_fax  NHACUNGCAP.FAXNCC%type,
        s_email NHACUNGCAP.EMAILNCC%type)
        IS 
        BEGIN 
        INSERT INTO NHACUNGCAP (MANCC, TENNCC, DIACHINCC, DIENTHOAINCC, FAXNCC, EMAILNCC) 
        VALUES(s_id, s_name, s_addr, s_phone,  s_fax, s_email ); 
        END addSupplier;
        --Thu tuc xoa thong tin nha cung cap
    PROCEDURE delSupplier(s_id   NHACUNGCAP.MANCC%type) IS 
        BEGIN 
        DELETE FROM NHACUNGCAP
        WHERE MANCC = s_id; 
        END delSupplier;
        --Thu in danh sach nha cung cap
    PROCEDURE listSupplier IS  CURSOR c_supplier is 
        SELECT  TENNCC FROM NHACUNGCAP; 
        TYPE c_list is TABLE OF NHACUNGCAP.TENNCC%type; 
           name_list c_list := c_list(); 
           counter integer :=0; 
        BEGIN 
        FOR n IN c_supplier LOOP 
        counter := counter +1; 
        name_list.extend; 
        name_list(counter) := n.TENNCC; 
        dbms_output.put_line(c_supplier%rowcount||' '||name_list(counter)); 
        END LOOP; 
        END listSupplier;
        END pk_sup_package; 
        /
        


--------------------------------------------
--------CALL PACKAGE---------------------  
        SET SERVEROUTPUT ON;
        DECLARE 
        BEGIN 
        DBMS_OUTPUT.put_line('----DANH SACH NHA CUNG CAP TRUOC ----');
        --In danh sach nha cung cap truoc
        pk_sup_package.listSupplier;
        --Them thong tin nha cung cap
        pk_sup_package.addSupplier('CC009', 'Viet Quy Phuong','Dong Nai','03255588','0234555','nhy@gmail.com'); 
        pk_sup_package.addSupplier('CC010', 'Thanh Long','Phu Yen','03255588','0234555','nhy@gmail.com');
        --Xoa thong tin nha cung cap
        pk_sup_package.delSupplier('CC009');
        DBMS_OUTPUT.put_line('                                    ');
        DBMS_OUTPUT.put_line('----DANH SACH NHA CUNG CAP SAU ----');
        --In danh sach nha cung cap sau
        pk_sup_package.listSupplier; 
        END; 


/* 4.2. Tao package pk_invoice_management trong do bao gom:
    - FUnction f_invoice_discounted_value co tham so dau vao la maHoaDon( invoice_id), tinh gia tri hoa don da giam gia cho khach va 
    xuat ra thong bao "Tong gia tri hoa don (ma hoa don) la: ....Sau khi giam gia con: ......"
        Neu hoa don co gia tri > 5.000.000 thì duoc giam 15% tong hoa don. Cai lai thì khong duoc giam
    --- Function f_check_invoice_existence co tham so dau vao la maHoadon (invoice_id), kiem tra su ton tai cua hoa don do
    --Procedure proc_list_invoice_details co tham so dau vao la maHoaDon (invoice_id), xuat thong tin danh sach san pham co trong
    hoa don do voi thong tin: Ma san pham, ten san pham, so luong, don gia, thanh tien*/


---------------------------TAO PACKAGE-----------------------------------
    CREATE OR REPLACE PACKAGE pk_invoice_management IS
        -- Function: Tinh gia hoa don da giam gia cho khach. X
        FUNCTION f_invoice_discounted_value(invoice_id IN nvarchar2) RETURN nVARCHAR2;
    
        -- Procedure: Xuat danh sach san pham co trong hoa don
        PROCEDURE proc_list_invoice_details(invoice_id IN nvarchar2);
    
        -- Function: Kiem tra su ton tai cua hoa don
        FUNCTION f_check_invoice_existence(invoice_id IN nvarchar2) RETURN BOOLEAN;
    
    END pk_invoice_management;


---------------------------TAO PACKAGE BODY-----------------------------------

    CREATE OR REPLACE PACKAGE BODY pk_invoice_management IS
        
        -- Function: Tinh gia hoa don da giam gia cho khach--
        --------------f_invoice_discounted_value---------------
        FUNCTION f_invoice_discounted_value(invoice_id IN nvarchar2) 
        RETURN nVARCHAR2
        IS
            tongHoaDon NUMBER := 0;
        BEGIN
            -- Lay tong gia tri hoa don
            SELECT SUM(SoLuongSP * DonGia) INTO tongHoaDon 
            FROM CTHoaDon
            WHERE MaHoaDon = invoice_id;
    
            -- Kiem tra neu tongHoaDon  > 5.000.000 thi giam 15%
            IF tongHoaDon > 5000000 THEN
                RETURN 'Tong gia tri hoa don '|| invoice_id ||' la: '||tongHoaDon
                       || '. Sau khi giam con: '|| tongHoaDon * 0.85;
            ELSE 
                RETURN 'Tong gia tri hoa don '|| invoice_id ||' la: '||tongHoaDon
                       || '. Hoa don khong duoc giam gia ' ;
            END IF;

        END f_invoice_discounted_value;
    
        -- Procedure: Xuat danh sach san pham co trong hoa don
        --------------proc_list_invoice_details---------------
         PROCEDURE proc_list_invoice_details(invoice_id IN nvarchar2) IS
         v_count number :=0;
        BEGIN
            -- Xuat danh sach san pham
            DBMS_OUTPUT.PUT_LINE(' ------CHI TIET HOA DON BAN -------');
            FOR invoice_item IN 
            (SELECT ct.MaSP, sp.TenSanPham, ct.SoLuongSP, ct.DonGia, ct.SoLuongSP * ct.DonGia AS ThanhTien
             FROM CTHoaDon ct 
             JOIN SanPham sp ON ct.MaSP = sp.MaSP
             WHERE ct.MaHoaDon = invoice_id) 
            LOOP
            v_count := v_count+1;
                DBMS_OUTPUT.PUT_LINE( v_count || '--- ' ||invoice_item.MaSP || '. ' || invoice_item.TenSanPham ||
                                      ', SL: ' || invoice_item.SoLuongSP || ', Don gia: ' || invoice_item.DonGia ||
                                      ', Thanh Tien: ' || invoice_item.ThanhTien);
            END LOOP;
        END proc_list_invoice_details;
        -- Function: Kiem tra hoa don nhap vao
         --------------f_check_invoice_existence---------------
        FUNCTION f_check_invoice_existence(invoice_id IN nvarchar2) 
        RETURN BOOLEAN 
        IS
            invoice_count NUMBER := 0;
        BEGIN
            -- Kiem tra su ton tai cua Hoa don trong csdl
            SELECT COUNT(*) INTO invoice_count
            FROM HoaDon
            WHERE MaHoaDon = invoice_id;
            
            IF invoice_count = 0 THEN
                RETURN FALSE;
            ELSE
                RETURN TRUE;
            END IF;
        END f_check_invoice_existence;
    
    END pk_invoice_management;



   --------------------------------------------
  --------CALL PACKAGE---------------------    
/*Ap dung package pk_invoice_management, Tao khoi lenh nhap vao MaHoaDon, kiem tra su ton tai cua hoa 
don do. Xuat thong tin tong gia tri hoa don sau khi giam gia va xuat thong tin chi tiet san pham trong hoa don.*/

SET SERVEROUTPUT ON;
    DECLARE
        i_invoice_id NVARCHAR2(100) := '&MAHOADON';
        invoice_exists BOOLEAN;
        discounted_value NVARCHAR2(100);
    BEGIN
        --------------- Kiem tra thong tin nhap vao ------------------------
        ---- Gia tri nhap vao la null NULL
        IF i_invoice_id IS NULL THEN
            RAISE_APPLICATION_ERROR(-20020, 'Ma hoa don khong duoc de trong');
        END IF;
    
        -- Kiem tra su ton tai cua hoa don
        invoice_exists := pk_invoice_management.f_check_invoice_existence(i_invoice_id);
    
        IF invoice_exists THEN
            -- Xuat thong tin san pham co trong hoa don
            pk_invoice_management.proc_list_invoice_details(i_invoice_id);
    
            -- Tinh gia tri hoa don sau khi giam gia va xuat thong tin
            DBMS_OUTPUT.PUT_LINE(pk_invoice_management.f_invoice_discounted_value(i_invoice_id));
        ELSE
            DBMS_OUTPUT.PUT_LINE('Hoa don ' || i_invoice_id || ' Khong ton tai');
        END IF;
    END;
    
    
        
/* 4.3. Tao package pk_BonusPackage gom :
   - Procedure pr_emp_bestsel_thang in thong tin chi tiet nhan vien voi tham so dau vao la Ma nhan vien,
tham so dau ra la TenNV, SDT, GioiTinh
   - Function f_CalculateBonus tinh tien thuong cua nhan vien voi tham so dau vao la Ma nhan vien
   - Function f_find_emp tim kiem Ma nhan vien co doanh so ban hang cao nhat trong thang va nam cu the
   voi Thang va Nam la tham so dau vao*/


---TAO PACKAGE
    CREATE OR REPLACE PACKAGE pk_BonusPackage AS
    -- Thu tuc in ra thong tin chi tiet nhan vien theo ma nhan vien
    PROCEDURE pr_emp_bestsel_thang
        (p_empid NHANVIEN.MANV%TYPE,
         v_tenNV OUT NHANVIEN.HOTEN%TYPE,
         v_luong OUT NHANVIEN.LUONG%TYPE);

    -- Hàm tinh tien thuong dua theo maNV
    FUNCTION f_CalculateBonus(p_empid IN NHANVIEN.MANV%TYPE) RETURN NUMBER;

    -- Hàm tim nhan vien co doanh so ban cao nhat trong thang va nam c? the
    FUNCTION f_find_emp(p_month IN INT, p_year IN INT) RETURN SYS_REFCURSOR;
    END pk_BonusPackage;



---TAO  PACKAGE BODY
    CREATE OR REPLACE PACKAGE BODY pk_BonusPackage AS
        ---------- pr_emp_bestsel_thang procedure------------------------
        PROCEDURE pr_emp_bestsel_thang
        (
            p_empid IN NHANVIEN.MANV%TYPE,
            v_tenNV OUT NHANVIEN.HOTEN%TYPE,
            v_luong OUT NHANVIEN.LUONG%TYPE
        )
        IS  
            
        BEGIN
            -- Lay thong tin nhan vien
            SELECT HOTEN, LUONG
                INTO v_tenNV, v_luong
            FROM NHANVIEN JOIN HOADON ON NHANVIEN.MANV = HOADON.MANV
            WHERE NHANVIEN.MANV = p_empid
            GROUP BY HOTEN, LUONG;
    
        END pr_emp_bestsel_thang;
        
        ---------- f_CalculateBonus function------------------------
        FUNCTION f_CalculateBonus(p_empid IN NHANVIEN.MANV%TYPE) 
        RETURN NUMBER 
        IS
            v_bonus NUMBER;
            v_luong NHANVIEN.LUONG%TYPE;
        BEGIN
            -- Lay luong nhan vien dua vao ma nhan vien
            SELECT LUONG INTO v_luong FROM NHANVIEN WHERE MANV = p_empid;
    
            -- Tinh tien thuong
            v_bonus := v_luong * 0.1;
            RETURN v_bonus;
        END f_CalculateBonus;
    
        ---------- f_find_emp function------------------------
        FUNCTION f_find_emp(p_month IN INT, p_year IN INT) RETURN SYS_REFCURSOR
        IS
            cursor_thongtinNV SYS_REFCURSOR;
        BEGIN
            OPEN cursor_thongtinNV FOR
            -- Tim nhan vien co doanh so ban hang cao nhat trong thang va nam cu the
            SELECT MANV, SUM(TONGGIATRI) 
            FROM HOADON
            WHERE EXTRACT(MONTH FROM NGAYLAP) =p_month
            AND EXTRACT(YEAR FROM NGAYLAP) = p_year
            GROUP BY MANV
            ORDER BY SUM(TONGGIATRI) DESC
            FETCH FIRST 1 ROW ONLY;
       
            RETURN cursor_thongtinNV;
        END f_find_emp;
    END pk_BonusPackage;
/


 -------------------------------------------
  --------CALL PACKAGE--------------------- 
    --------------------------------------------------------
/* Viet khoi lenh nhap vao Thang va nam, tim kiem nhan vien co doanh so ban hang cao nhat, in ra 
thong tin chi tiet cua nhan vien do va tinh tien thuong cho nhan vien do*/

SET SERVEROUTPUT ON;
DECLARE
    cursor_nv SYS_REFCURSOR;
    v_maNV NHANVIEN.MANV%TYPE;
    v_doanhSo NUMBER;
    v_month_char nvarchar2(10) := '&MONTH'; p_month int;
    v_year_char nvarchar2(10) := '&YEAR';   p_year int;
    v_tenNV NHANVIEN.HOTEN%TYPE;
    v_luong NHANVIEN.LUONG%TYPE;
BEGIN
    IF NOT REGEXP_LIKE ( v_month_char, '^[0-9]+$') OR NOT REGEXP_LIKE ( v_year_char, '^[0-9]+$') 
    THEN RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap dung dinh dang'); 
    ELSIF v_month_char IS NULL OR v_year_char IS NULL
    THEN RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap day du thong tin');
    ELSE
        p_month := to_number(v_month_char);
        p_year := to_number (v_year_char);
    END IF;

    cursor_nv := pk_BonusPackage.f_find_emp(p_month, p_year);

    LOOP
        FETCH cursor_nv INTO v_maNV, v_doanhSo;
        EXIT WHEN cursor_nv%NOTFOUND;

        IF cursor_nv%FOUND THEN
            DBMS_OUTPUT.put_line('*NHAN VIEN CO DOANH SO BAN HANG CAO NHAT TRONG THANG: '|| p_month || '/' || p_year);
            DBMS_OUTPUT.put_line('     Ma nhan vien: ' || v_maNV);
            DBMS_OUTPUT.put_line('     Doanh so trong thang: ' || v_doanhSo);
            DBMS_OUTPUT.put_line(' ===> Muc thuong: '|| pk_BonusPackage.f_CalculateBonus(v_maNV));
            
            pk_BonusPackage.pr_emp_bestsel_thang(v_maNV, v_tenNV, v_luong);
            -- In thong tin nhan vien
            DBMS_OUTPUT.PUT_LINE('-------Thong tin chi tiet nhan vien------------:');
            DBMS_OUTPUT.PUT_LINE('Ten nhan vien: ' || v_tenNV);
            DBMS_OUTPUT.PUT_LINE('Luong: ' || v_luong);
        ELSE 
            DBMS_OUTPUT.put_line('Khong tim thay nhan vien nao co doanh so cao nhat trong thang ' || p_month || '/' || p_year);
        END IF;
    END LOOP;

    CLOSE cursor_nv;
END;




--4.4.Tao package pk_PDUCT_SUPPLIER gom ham f_get_same_supplier_product de lay danh sach cac san pham co
-- cung nha cung cap va thu tuc pk_PDUCT_SUPPLIER voi tham so dau vao la masp in ra thong tin nha cung cap

--------TAO PACKAGE----------------------
    CREATE OR REPLACE PACKAGE pk_PDUCT_SUPPLIER AS
    --Dinh nghia ham f_get_same_supplier_product
    FUNCTION  f_get_same_supplier_product(pduct_id SANPHAM.MASP%TYPE) 
    RETURN SYS_REFCURSOR;       
    --Dinh nghia thu tuc pr_product
    PROCEDURE pr_product
    (
        p_duct IN SANPHAM.MASP%TYPE,
        o_sup_id  OUT NHACUNGCAP.MANCC%type,
        o_name OUT NHACUNGCAP.TENNCC%type,
        o_fax OUT NHACUNGCAP.FAXNCC%type,
        o_name_duct OUT SANPHAM.TENSANPHAM%type
    );
    END pk_PDUCT_SUPPLIER;
    /
    
    
-------TAO PACKAGE BODY ----------------------
        CREATE OR REPLACE PACKAGE BODY pk_PDUCT_SUPPLIER AS
        
        ---------- f_get_same_supplier_product function------------------------
        FUNCTION f_get_same_supplier_product(pduct_id SANPHAM.MASP%TYPE) RETURN SYS_REFCURSOR IS
            product_names_cursor SYS_REFCURSOR;
            sup_id NhaCungCap.MaNCC%TYPE;
        BEGIN
            SELECT NHACUNGCAP.MANCC INTO sup_id
            FROM (NHACUNGCAP JOIN NHAPHANG ON NHACUNGCAP.MANCC=NHAPHANG.MANCC)
                JOIN CTNHAPHANG ON NHAPHANG.MANHAPHANG=CTNHAPHANG.MANHAPHANG
                JOIN SANPHAM ON CTNHAPHANG.MASP=SANPHAM.MASP
            WHERE SANPHAM.MASP = pduct_id;
    
            OPEN product_names_cursor FOR
            SELECT  SANPHAM.MASP, TENSanPham
            FROM (NHACUNGCAP JOIN NHAPHANG ON NHACUNGCAP.MANCC=NHAPHANG.MANCC)
                JOIN CTNHAPHANG ON NHAPHANG.MANHAPHANG=CTNHAPHANG.MANHAPHANG
                JOIN SANPHAM ON CTNHAPHANG.MASP=SANPHAM.MASP
            WHERE NHACUNGCAP.MANCC = sup_id;
    
            RETURN product_names_cursor;
        END f_get_same_supplier_product;
    
     ---------- pr_product PROCEDURE------------------------
        PROCEDURE pr_product(
            p_duct IN SANPHAM.MASP%TYPE,
            o_sup_id OUT NHACUNGCAP.MANCC%TYPE,
            o_name OUT NHACUNGCAP.TENNCC%TYPE,
            o_fax OUT NHACUNGCAP.FAXNCC%TYPE,
            o_name_duct OUT SANPHAM.TENSANPHAM%TYPE
        ) IS
        BEGIN
            SELECT NHACUNGCAP.MANCC, TENNCC, FAXNCC, TENSANPHAM
            INTO o_sup_id, o_name, o_fax, o_name_duct
            FROM (NHACUNGCAP JOIN NHAPHANG ON NHACUNGCAP.MANCC=NHAPHANG.MANCC)
                JOIN CTNHAPHANG ON NHAPHANG.MANHAPHANG=CTNHAPHANG.MANHAPHANG
                JOIN SANPHAM ON CTNHAPHANG.MASP=SANPHAM.MASP
            WHERE SANPHAM.MASP = p_duct;
        END pr_product;
    END pk_PDUCT_SUPPLIER;
        /
        
        
     
 -------------------------------------------
--------CALL PACKAGE-----------------------      
/* Ap dung package pk_PDUCT_SUPPLIER , viet khoi lenh nhap vao Ma san pham, xuat ra thong tin nha 
cung cap san pham do. Dong thoi xuat danh sach cac san pham co cung nha cung cap tren*/

    SET SERVEROUTPUT ON;
    DECLARE
        cursor_sp SYS_REFCURSOR;
        pduct_id SANPHAM.MASP%TYPE := '&MASANPHAM';  ---MASP: NT004
        p_name_duct SANPHAM.TENSANPHAM%TYPE;
        p_name_pduct NhaCungCap.TenNCC%type;
        p_id_pduct NhaCungCap.MaNCC%type;
        p_fax_pduct NhaCungCap.FaxNCC%type;
        v_SanPhamExists  number;
        
        p_same_nameSP SANPHAM.TENSANPHAM%TYPE;
        p_same_idSP SANPHAM.MASP%TYPE;
        
    BEGIN
    
        --------------- Kiem tra thong tin nhap vao------------------------
        BEGIN
            -- Kiem tra gia tri null
            IF pduct_id IS NULL THEN
                RAISE_APPLICATION_ERROR(-20020, 'Vui long nhap day du thong tin');
            END IF;
           
            -- Kiem tra su ton tai cua pduct_id trong bang SanPham
            SELECT COUNT(*) INTO v_SanPhamExists
            FROM SanPham
            WHERE MaSP = pduct_id;
        
            IF v_SanPhamExists = 0 THEN
                RAISE_APPLICATION_ERROR(-20020,'San pham co ma ' || pduct_id || ' khong ton tai');
            END IF;
        END;
        
        pk_PDUCT_SUPPLIER.pr_product(pduct_id, p_id_pduct, p_name_pduct, p_fax_pduct, p_name_duct);
                
        -- Display product information
        DBMS_OUTPUT.put_line('*--------THONG TIN SAN PHAM CO MA: '|| pduct_id ||'--------------');
        DBMS_OUTPUT.put_line('    Ten san pham: ' || p_name_duct);
        DBMS_OUTPUT.put_line('    Ma NCC: '||p_id_pduct|| '. Ten nha cung cap: ' || p_name_pduct);
        DBMS_OUTPUT.put_line('    Fax: '|| p_fax_pduct);
            
        -- Retrieve products with the same supplier
        cursor_sp := pk_PDUCT_SUPPLIER.f_get_same_supplier_product(pduct_id);
        DBMS_OUTPUT.put_line('-------------------------------------------------');
        DBMS_OUTPUT.put_line('*DANH SACH SAN PHAM CO NHA CUNG CAP TUONG TU: ');
        
        LOOP
            FETCH cursor_sp INTO p_same_idSP, p_same_nameSP;
            EXIT WHEN cursor_sp%NOTFOUND;
              DBMS_OUTPUT.put_line(cursor_sp%rowcount || '. ' || p_same_idSP ||' - ' || p_same_nameSP);
        END LOOP;    
        
        CLOSE cursor_sp;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20020,' Chua cap nhat thong tin Nha Cung cap cho san pham '||pduct_id );
        
    END;
            
            
 
  ---------5. TRIGGER----------------
---------------------------------------------------------------------------------------------------

/* 5.1. Tao trigger trig_nguoilapphieu_NhapHang cho phep nhan vien thuoc bo phan kho moi duoc  lap va chinh sua thong tin NhapHang.
    Hien thi thong bao sau khi cap nhat. */
    
    -- Cau lenh
    CREATE OR REPLACE TRIGGER trig_nguoilapphieu_NhapHang
    BEFORE INSERT OR UPDATE ON NhapHang
    FOR EACH ROW
    DECLARE
        v_TenBP BoPhan.TenBP%TYPE;
    BEGIN
        SELECT TenBP INTO v_TenBP 
        FROM NhanVien nv join BoPhan bp on nv.MaBP = bp.MaBP 
        WHERE MaNV = :NEW.MaNV;
        
         IF UPPER(v_TenBP) != 'NHAN VIEN QUAN LY KHO' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Nhan vien khong thuoc bo quan ly kho. Khong 
                                        co quyen tao Phieu Nhap Hang !!!!!');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Thong tin da duoc cap nhat thanh cong!');
        END IF;
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE_APPLICATION_ERROR(-20003, '!!!!LOI.Khong tim thay thong tin du lieu!');
    END;
    
    
    ------Kiem thu trigger trig_nguoilaphoadon---------------------
    SET SERVEROUTPUT ON; -- ERROR: Nhan vien khong thuoc bo quan ly kho. Khong co quyen tao Phieu Nhap Hang 
    INSERT INTO NHAPHANG VALUES ('nh100', TO_DATE('2023-11-25', 'YYYY-MM-DD'),  'NV003', 'CC001');
    
    SET SERVEROUTPUT ON;--- ERROR: !!!!LOI.Khong tim thay thong tin du lieu!
     INSERT INTO NHAPHANG VALUES ('nh100', TO_DATE('2023-11-25', 'YYYY-MM-DD'),  'NV00e', 'CC001');
     
     SET SERVEROUTPUT ON; --  Thong tin da duoc cap nhat thanh cong
     INSERT INTO NHAPHANG VALUES ('nh100', TO_DATE('2023-11-25', 'YYYY-MM-DD'),  'NV009', 'CC001'); 
     
     
     
     ----------------------------------------------------------------------------------------
/* 5.2. Tao trigger trg_CheckEmailFormat kiem tra email nhap vao cua Nhan vien phai dung dinh dang Email.*/
     
     CREATE OR REPLACE TRIGGER trg_CheckEmailFormat
    BEFORE INSERT OR UPDATE OF Email ON NhanVien
    FOR EACH ROW
    BEGIN
        -- Kiem tra dinh dang Email
        if NOT REGEXP_LIKE(:new.Email, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$') THEN
            RAISE_APPLICATION_ERROR(-20001, 'Vui long nhap dung dinh dang email');
        else
            DBMS_OUTPUT.PUT_LINE('Da cap nhat thanh cong thong tin Nhan vien!');
            DBMS_OUTPUT.PUT_LINE(' NV: '|| :new.MaNV ||'. '|| :new.HoTen);
        END IF;
    END;
     
        
    ------Kiem thu trigger trg_CheckEmailFormat---------------------
        
     SET SERVEROUTPUT ON;-- ERROR: EMAIL khong hop le
     INSERT into NHANVIEN VALUES ('NV1001', N'Nguyen Thuy Dung', N'Nu', N'0398874556',N'ThuyDunggmail.com',3,9000000);
     
      UPDATE NHANVIEN -- ERROR: EMAIL khong hop le
     SET Email ='ThuyDung@gmailcom'
     WHERE MaNV ='NV1001';
     
      SET SERVEROUTPUT ON; -- EMAIL hop le
     INSERT into NHANVIEN VALUES ('NV1001', N'Nguyen Thuy Dung', N'Nu', N'0398874556',N'ThuyDung@yahoo.com',3,8000000);
     

     
     
          -------------------------------------------------------------------
 /* 5.3. Tao trigger trg_TinhTongDoanhThu de tu dong tinh tong doanh thu khi tao them hoac sua thong tin 
 vao bang BAOCAODOANHTHUTHANG  .*/         
          
    CREATE OR REPLACE TRIGGER trg_TinhTongDoanhThu
    BEFORE INSERT OR UPDATE ON BAOCAODOANHTHUTHANG
    FOR EACH ROW
    declare  v_tongdoanhthu number;

    BEGIN
         -- Tinh Tong doanh thu  
         SELECT NVL(SUM(SoLuongSP*DonGia),0) INTO v_tongdoanhthu
        FROM  HoaDOn hd join CTHoaDon ct on hd.MaHoaDon = ct.MaHoaDon
        WHERE EXTRACT(month FROM hd.NGAYLAP) = :new.Thang
                and EXTRACT(year FROM hd.NGAYLAP) = :new.Nam;
          
        :new.TongDoanhThu := v_tongdoanhthu;
    DBMS_OUTPUT.PUT_LINE('Da cap nhat thanh cong Bao cao doanh thu thang ' || :new.Thang || '/' ||:new.Nam
                        || ' cho bao cao ' || :new.MaBC);        
    END;
    
    --Kiem thu
     SET SERVEROUTPUT ON;
     insert into BAOCAODOANHTHUTHANG (MaBC, TenBC,Thang,Nam) values ('BC08','BAO CAO DOANH THU',8,2023);
    
    
    update BAOCAODOANHTHUTHANG
    set Thang =10 
    where MaBC ='BC08';
    
    
    
   ------------------------------------------------------------------- 
/* 5.4. Tao trigger trg_CapNhatSoLuongTon_NhapHang cap nhat so luong ton cua SanPham khi them CTNhapHang */   

    CREATE OR REPLACE TRIGGER trg_CapNhatSoLuongTon_NhapHang
    AFTER INSERT ON CTNhapHang
    FOR EACH ROW
    declare v_SLT number;
    BEGIN 
            UPDATE SanPham
            SET SOLUONGTON = SOLUONGTON + :new.SOLUONG
            WHERE MaSP = :NEW.MaSP;
            
            select SOLUONGTON into v_SLT from SanPham WHERE MaSP = :NEW.MaSP;
            DBMS_OUTPUT.PUT_LINE (' Da them ' ||:new.SOLUONG || ' San pham: '|| :new.MaSP || 
                                    ' vao Phieu nhap hang');
            DBMS_OUTPUT.PUT_LINE (' So luong ton cu cua san pham: ' || (v_SLT -:new.SOLUONG));
            DBMS_OUTPUT.PUT_LINE (' Cap nhat thanh cong.So luong ton hien tai cua san pham '||
                                    :new.MaSP || ' la: '|| v_SLT);    
        
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
           RAISE_APPLICATION_ERROR(-20003, '!!!!LOI.Khong tim thay thong tin du lieu!');
             
    END; 


    ----kiem thu----
   
    SET SERVEROUTPUT ON;-- ERROR:NO_DATA_FOUND
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PN00a', 'NH001', 10);
    
    SET SERVEROUTPUT ON; -- Thong tin da duoc cap nhat thanh cong
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PN002', 'NH001', 20);
    
    
    
     -------------------------------------------------------------------
    /* 5.5. CHo phep nhan vien thay doi bang BAOCAODOANHTHUTHANG vao ngay 28 hang thang */   --- BEFORE STATEMENT

     CREATE OR REPLACE TRIGGER trg_ThoiGianTaoBaoCao
    BEFORE INSERT or update or delete ON BAOCAODOANHTHUTHANG
    declare 
        v_day number;
    BEGIN 
            v_day := TO_NUMBER(TO_CHAR(SYSDATE, 'DD'));
     
            IF v_day != 28 THEN
                RAISE_APPLICATION_ERROR(-20001, 'Chua den thoi gian tao bao cao');
            else 
                DBMS_OUTPUT.PUT_LINE ('Cap nhat bao cao thanh cong.!');
            end if;
    END;

    
    --Kiem thu
     SET SERVEROUTPUT ON;
     insert into BAOCAODOANHTHUTHANG (MaBC, TenBC,Thang,Nam) values ('BC09','BAO CAO DOANH THU ',2,2023 );

    SET SERVEROUTPUT ON;
     update BAOCAODOANHTHUTHANG
     set Thang = 8 
     where MaBC = 'BC08';




    
    
/* 5.6. Cap nhat bang TONGLUONGNHANVIEN de ghi chep lai thong tin khi thay doi thong tin Luong cua NhanVien  */
---AFTER STATEMENT

    -- Tao bang TONGLUONGNHANVIEN
        create table TONGLUONGNHANVIEN
        (
            TongLuongPhaiTraNV number,
            ThoigianCapNhat date not null
        );
            
       
    -------Cau lenh  
    CREATE OR REPLACE TRIGGER trg_AfterInsert_TONGLUONGNV
    AFTER INSERT OR UPDATE ON NHANVIEN
    DECLARE
        v_Total NUMBER;
    BEGIN
        -- Tính tong luong phai tra cho Nhanvien
        SELECT SUM(Luong) INTO v_Total
        FROM NhanVien;
    
        -- Ghi thong tin ve viec thay doi TongLuongPhaiTraNV khi thay doi Luong cua NhanVien
        INSERT INTO TONGLUONGNHANVIEN  VALUES ( v_Total ,SYSDATE);
    
         DBMS_OUTPUT.PUT_LINE (' Cap nhat thanh cong');
        DBMS_OUTPUT.PUT_LINE ('Da cap nhat Tong luong phai tra cho nhan vien : ' || v_Total || 
                        ' vao luc  ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS'));

    END;


-- Kiem thu
    SET SERVEROUTPUT ON;
    update  NhanVien
    set Luong = 15000000
    where MaNV = 'QL001';
    
    SET SERVEROUTPUT ON;
    INSERT into NHANVIEN VALUES ('NV100', N'Phan Van Tri',  N'Nam', N'0398874698',N'Phantri@gmail.com',3,9000000);
    
    
/* 5.7. instead of trigger */
    /* Tao trigger cho phep khi xoa mot phieu nhap hang trong view vw_NhapHang thi tu dong xoa luon phieu nhap hang do
    trong b?ng NhapHang va cac chi tiet nhap hang lien quan */
    
    --Cau lenh
    CREATE OR REPLACE TRIGGER trg_delete_NhapHang
    INSTEAD OF Delete ON vw_NhapHang
    FOR EACH ROW
    BEGIN
        
        Delete from CTNhapHang where MaNhapHang = :old.MaNhapHang;
        Delete from NhapHang where MaNhapHang = :old.MaNhapHang; 
        DBMS_OUTPUT.PUT_LINE ('Da xoa PhieuNhap va CTPhieuNhap co ma: '|| :old.MaNhapHang);
        
    END;
    
    --- Cau lenh kiem thu 
    delete from vw_NhapHang where MaNhapHang = '&MANHAPHANG' --NH0010
    
    -- Xem lai view 
    select * from vw_NhapHang
    
    

/*  compound trigger*/
  
/* 5.8. Tao trigger trg_SOLUONGTON_CTHoaDOn de khi them thong tin CTHOADON ràng buoc gia tri cua SoLuongSP > 0 và <= SOLUONGTON có trong b?ng SanPham
 , gia tri DonGia >0 . Dong thoi khi them thong tin CTHOADON cap nhat lai SOLUONGTON cua SanPham*/
        
    

    CREATE OR REPLACE TRIGGER trg_SOLUONGTON_ThemCTHoaDOn
        FOR INSERT ON CTHoaDon
        COMPOUND TRIGGER
                v_SLT NUMBER;
        
        BEFORE EACH ROW IS
        BEGIN 
            SELECT SOLUONGTON INTO v_SLT FROM SanPham  WHERE MaSP = :NEW.MaSP;
            
            IF (:NEW.SOLUONGSP > v_SLT) THEN
                RAISE_APPLICATION_ERROR(-20001, 'So luong hang trong kho khong du ban. Vui lòng chon 
                                        lai So luong san pham bán ra phai nho hon ' || v_SLT);
            end if;
            if (:new.SoLuongSP <= 0) then
                RAISE_APPLICATION_ERROR(-20001, 'Yeu cau So luong hang ban ra phai lon hon 0');
            end if;
            if (:new.DonGia < 0) then
                RAISE_APPLICATION_ERROR(-20001, 'Don gia khong hop le.Yeu cau Don gia ban lon hon 0');
            end if;
       
        END BEFORE EACH ROW;
        
        AFTER EACH ROW IS
        BEGIN
    
                --- Cap nhat SoLuongTon cho bang SanPham
                    Select SOLUONGTON into v_SLT
                    from SanPham
                    where MaSP = :new.MaSP;
                    
                    UPDATE SanPham
                    SET SOLUONGTON = v_SLT - :new.SOLUONGSP
                    WHERE MaSP = :NEW.MaSP;
                
                DBMS_OUTPUT.PUT_LINE (' Cap nhat thanh cong. So luong ton hien tai cua san pham '|| 
                                    :new.MaSP || ' la: '|| (v_SLT - :NEW.SOLUONGSP) );             
              
        END AFTER EACH ROW;
    
    END ;
\


    ---KIEM THU-----------
        -- ERROR: So luong hang ban ra <= 0
       INSERT INTO CTHOADON (MAHOADON,MASP,SOLUONGSP,DONGIA) VALUES ('HD007','NT006',-10,30000); 
       
       
       -- ERROR: So luong hang ban ra > So luong ton trong kho
       INSERT INTO CTHOADON (MAHOADON,MASP,SOLUONGSP,DONGIA) VALUES ('HD007','NT006',10000,30000); 
       
       -- ERROR: Don Gia ban ra < 0
       INSERT INTO CTHOADON (MAHOADON,MASP,SOLUONGSP,DONGIA) VALUES ('HD007','NT006',10,-30000); 
       
       -- Thong tin hop le
       INSERT INTO CTHOADON (MAHOADON,MASP,SOLUONGSP,DONGIA) VALUES ('HD007','NT006',10,30000); 
       
       
    
    ---------6.USER AND ROLE----------------
---------------------------------------------------------------------------------------------------  

/* 6.1. TAO 3 ROLE: QUAN LY, NHAN VIEN KHO, NHAN VIEN BAN HANG*/
-- Tao role theo Bo phan
    CREATE ROLE QUANLY;
    CREATE ROLE NHANVIENKHO;
    CREATE ROLE NHANVIENBANHANG;
    
--Xem cac role hien co
    SELECT role FROM dba_roles;

/* 6.2. TAO 6 USER*/
-- Tao User
    CREATE USER NV_NGUYENTHUYDUNG IDENTIFIED BY 123456;
    CREATE USER NV_LETHIHOA IDENTIFIED BY 123456;
    CREATE USER NV_LyThuThu IDENTIFIED BY 123456;
    CREATE USER NV_NguyenTan IDENTIFIED BY 123456;
    CREATE USER NV_PhanVanAnh IDENTIFIED BY 123456;
    CREATE USER NV_TranThiThanh IDENTIFIED BY 123456;
    
--Xem cac user hien co
    SELECT username FROM all_users;


/* 6.3. CAP QUYEN CHO ROLE QUAN LY*/
    grant create session to QUANLY;
    
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.BAOCAODOANHTHUTHANG TO QUANLY ;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.BOPHAN TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.CHATLIEU TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.CTHOADON TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.CTNHAPHANG TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.HOADON TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.KHACHHANG TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.MAUSAC TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.NHACUNGCAP TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.NHANVIEN TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.NHAPHANG TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.NHOM TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.SANPHAM TO QUANLY;
    GRANT ALL ON VIWOOD_NGUYENTHUYDUNG.TONGLUONGNHANVIEN TO QUANLY;


    --- Xem quyen da cap cho ROLE 'QUANLY'
    SELECT * 
    FROM ROLE_TAB_PRIVS
    WHERE ROLE = 'QUANLY';

/* 6.4. CAP QUYEN CHO ROLE NHANVIENKHO*/
    grant create session to NHANVIENKHO;
    
    GRANT SELECT ON VIWOOD_NGUYENTHUYDUNG.BOPHAN TO NHANVIENBANHANG;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.CHATLIEU TO NHANVIENKHO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.CTNHAPHANG TO NHANVIENKHO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.MAUSAC TO NHANVIENKHO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.NHACUNGCAP TO NHANVIENKHO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.NHAPHANG TO NHANVIENKHO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.NHOM TO NHANVIENKHO;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.SANPHAM TO NHANVIENKHO;

     --- Xem quyen da cap cho ROLE 'NHANVIENKHO'
    SELECT * 
    FROM ROLE_TAB_PRIVS
    WHERE ROLE = 'NHANVIENKHO';

/* 6.5. CAP QUYEN CHO ROLE NHANVIENBANHANG*/
    grant create session to NHANVIENBANHANG;
    
    GRANT SELECT ON VIWOOD_NGUYENTHUYDUNG.BOPHAN TO NHANVIENBANHANG;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.CTHOADON TO NHANVIENBANHANG;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.HOADON TO NHANVIENBANHANG;
    GRANT SELECT, INSERT, UPDATE, DELETE ON VIWOOD_NGUYENTHUYDUNG.KHACHHANG TO NHANVIENBANHANG;
    GRANT SELECT ON VIWOOD_NGUYENTHUYDUNG.NHANVIEN TO NHANVIENBANHANG;
    GRANT SELECT ON VIWOOD_NGUYENTHUYDUNG.SANPHAM TO NHANVIENBANHANG;


    --- Xem quyen da cap cho ROLE 'NHANVIENBANHANG'
    SELECT * 
    FROM ROLE_TAB_PRIVS
    WHERE ROLE = 'NHANVIENBANHANG';
    
/* 6.6. GÁN ROLE CHO USER*/

    GRANT QUANLY TO NV_NGUYENTHUYDUNG;
    GRANT NHANVIENKHO TO NV_LETHIHOA;
    GRANT NHANVIENBANHANG TO NV_LyThuThu;
    GRANT NHANVIENBANHANG TO NV_NguyenTan;
    GRANT NHANVIENBANHANG TO NV_PhanVanAnh;
    GRANT NHANVIENBANHANG TO  NV_TranThiThanh;


    SELECT GRANTEE
    FROM DBA_ROLE_PRIVS
    WHERE GRANTED_ROLE = 'QUANLY';



show user;           
            















          