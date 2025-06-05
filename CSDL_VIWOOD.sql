---------1. TAO CAC BANG CHO CO SO DU LIEU----------------
----------------------------------------------------------
---TAO BANG BoPhan
    CREATE TABLE BoPhan 
    (
        MaBP varchar (20) NOT NULL,
        TenBP  nvarchar2 (50) NOT NULL,
        MoTa    nvarchar2 (200) NOT NULL,
        primary key (MaBP)
    )
    
-- TAO BANG NhanVien
    CREATE TABLE  NhanVien 
    (
         MaNV   varchar (20) primary key ,
         HoTen   nvarchar2 (100) NOT NULL,
         GioiTinh  nvarchar2 (10) NOT NULL,
         SDT   nvarchar2 (15) NOT NULL,
         Email  nvarchar2 (150) NOT NULL,
         MaBP   varchar (20) NOT NULL,
         Luong  number  NOT NULL
    )


--TAO BANG KhachHang    
    CREATE TABLE   KhachHang  
    (
         MaKH    varchar  (20) primary key,
         HoTenKH      nvarchar2  (100) NOT NULL,
         DiaChiKH      nvarchar2  (100) NOT NULL,
         SDTKH      nvarchar2  (12) NOT NULL,
         EmailKH      nvarchar2  (50) NOT NULL,
         GioiTinhKH      nvarchar2  (10) NOT NULL
    )
    
    
--TAO BANG NhaCungCap  
    CREATE TABLE  NhaCungCap  
    (
         MaNCC    varchar  (20) primary key,
         TenNCC      nvarchar2  (50) NOT NULL,
         DiaChiNCC      nvarchar2  (100) NOT NULL,
         DienThoaiNCC    varchar  (12) NOT NULL,
         FaxNCC      nvarchar2  (12) NOT NULL,
         EmailNCC      nvarchar2  (100) NOT NULL
    )
   
    
--TAO BANG MauSac   
    CREATE TABLE  MauSac  
    (
         MaMS  varchar  (20) primary key,
         TenMauSac   nvarchar2  (100) NOT NULL
    )
    
    
 --TAO BANG Nhom     
    CREATE TABLE  Nhom  
    (
         MaNhom    varchar  (20) primary key,
         TenNhom   nvarchar2  (100) NOT NULL
    )
    

-- TAO BANG ChatLieu
    CREATE TABLE  ChatLieu 
    (
         MaChatLieu   varchar (20) primary key,
         TenChatLieu     nvarchar2 (100) NOT NULL
     )


--TAO BANG SanPham
    CREATE TABLE SanPham 
    (
         MaSP   varchar (20) primary key ,
         TenSanPham     nvarchar2 (100) NOT NULL,
         SoLuongTon    number   NOT NULL,
         GiaBan   number  NOT NULL,
         MoTa     nvarchar2 (300) NOT NULL,
         MaNhom   varchar (20) NOT NULL,
         MaChatLieu   varchar (20) NOT NULL,
         MaMS   varchar (20) NOT NULL
    )
    
-- TAO BANG HoaDon
    CREATE TABLE  HoaDon 
    (
         MaHoaDon   varchar (20) primary key ,
         NgayLap   date  NOT NULL,
         TongGiaTri number not null,
         MaNV   varchar (20) NOT NULL,
         MaKH   varchar (20) NOT NULL
    )
    
-- TAO BANG CTHoaDon
    CREATE TABLE  CTHoaDon 
    (
         MaHoaDon   varchar (20) NOT NULL,
         MaSP   varchar (20) NOT NULL,
         SoLuongSP   number  NOT NULL,
         DonGia   number  NOT NULL,
         primary key  (MaHoaDon,MaSP)
    )


    
--- TAO BANG NhapHang   
    CREATE TABLE  NhapHang  
    (
         MaNhapHang    varchar  (20) primary key ,
         NgayNhapHang    date   NOT NULL,
         MaNV    varchar  (20) NOT NULL,
         MaNCC    varchar  (20) NOT NULL
    )
    
    
 --- TAO BANG CTNhapHang
    CREATE TABLE  CTNhapHang 
    (
         MaSP   varchar (20) NOT NULL,
         MaNhapHang   varchar (20) NOT NULL,
         SoLuong   number  NOT NULL,
         primary key  (MaNhapHang, MaSP)
    )
     

 --- TAO BANG BaoCao
    CREATE TABLE BAOCAODOANHTHUTHANG
    ( 
        MaBC varchar(10) primary key,
        TenBC nvarchar2 (100) ,
        Thang number,
        Nam number,
        TongDoanhThu number 
    )  
 
 ---------2. THEM KHOA NGOAI + RANG BUOC CHO CAC BANG VA THUOC TINH----------------
---------------------------------------------------------------------------------------------------


/* 1. BANG NhanVien */
----Tao rang buoc khoa ngoai cua bang NhanVien voi MaBP tham chieu den MaBP cua bang BoPhan */
    ALTER TABLE NhanVien ADD CONSTRAINT fk_MaBP_NhanVien FOREIGN KEY (MaBP) REFERENCES BoPhan(MaBP);
    
-- Rang  buoc gia tri cua thuoc tinh GioiTinh la 'Nam' hoac 'Nu'
    ALTER TABLE NhanVien ADD CONSTRAINT ck_GioiTinh_NhanVien CHECK (GioiTinh  IN (N'Nam', N'Nu'))
    ALTER TABLE NhanVien ADD CONSTRAINT ck_Luong_NhanVien CHECK (Luong > 0 )

    -----------------------------

/* 3. BANG KhachHang */  
-- Rang  buoc gia tri cua thuoc tinh GioiTinhKH la 'Nam' hoac 'Nu' hoac 'Khac'
    ALTER TABLE KhachHang ADD CONSTRAINT ck_GioiTinh_KhachHang CHECK (GioiTinhKH  IN (N'Nam', N'Nu',N'Khac'))
    
     -----------------------------
    
/* 4. BANG SanPham */
-- Tao rang buoc khoa ngoai cua bang SanPham voi MaNhom, MaChatLieu, MaMS tham chieu den lan luot cac bang Nhom, 
--ChatLieu,MauSac
alter table SanPham add constraint fk_MaNhom_SanPham foreign key (MaNhom) references Nhom(MaNhom);
alter table SanPham add constraint fk_MaChatLieu_SanPham foreign key (MaChatLieu) references ChatLieu(MaChatLieu);
alter table SanPham add constraint fk_MaMS_SanPham foreign key (MaMS) references MauSac(MaMS);
    

    
     -----------------------------
    
/* 5. BANG HoaDon */
-- Tao rang buoc khoa ngoai cua bang HoaDon voi MaNV va MaKH tham chieu den lan luot cac bang 
--NhanVien, KhachHang
alter table HoaDon add constraint fk_hd_MaNV foreign key (MaNV) references NhanVien(MaNV);
alter table HoaDon add constraint fk_hd_MaKH foreign key (MaKH) references KhachHang(MaKH);
    
     -----------------------------
     
/* 6. BANG CTHoaDon */
-- Tao rang buoc khoa ngoai cua bang CTHoaDon voi MaSP va MaHoaDOn  tham chieu den lan luot cac bang SanPham va HoaDon
    alter table CTHoaDon add constraint fk_CTHoaDon_MaSP foreign key (MaSP ) references SanPham(MaSP );
    alter table CTHoaDon add constraint fk_CTHoaDon_MaHoaDon foreign key (MaHoaDon ) references HoaDon (MaHoaDon);
    

    
     -----------------------------

/* 7. BANG NhapHang */
-- Tao rang buoc khoa ngoai cua bang NhapHang voi MaNV va MaNVV tham chieu den lan luot cac bang 
----NhanVien, NhaCungCap
    alter table NhapHang add constraint fk_nh_MaNV foreign key (MaNV) references NhanVien(MaNV);
    alter table NhapHang add constraint fk_nh_MaNCC foreign key (MaNCC) references NhaCungCap(MaNCC);
    
     -----------------------------
    
/* 8. BANG CTNhapHang*/
--Tao rang buoc khoa ngoai cua bang CTNhapHang voi MaSP va MaNhapHang tham chieu den lan luot cac bang SanPham và NhapHang
    alter table CTNhapHang add constraint fk_ctnh_MaNhapHang foreign key (MaNhapHang) references NhapHang(MaNhapHang);
    alter table CTNhapHang  add constraint fk_ctnh_MaSP foreign key (MaSP) references SanPham(MaSP);
     
    
     -----------------------------
      
    
/* 9. BANG BAOCAODOANHTHUTHANG */    
-- Rang  buoc gia tri cua thuoc tinh Thang bang BANG BAOCAODOANHTHUTHANG >=1 va <= 12  
      ALTER TABLE BAOCAODOANHTHUTHANG ADD CONSTRAINT ck_thang_BAOCO CHECK (Thang >=1 and Thang <=12)  
 ---------3. INSERT DU LIEU VAO CAC BANG----------------
---------------------------------------------------------------------------------------------------

    INSERT into CHATLIEU VALUES (N'cl001', N'Go tu nhien');
    INSERT into CHATLIEU VALUES (N'cl002', N'Go ep loai 1');
    INSERT into CHATLIEU VALUES (N'cl003', N'Go ep loai 2');
    INSERT into CHATLIEU VALUES (N'cl004', N'Go ep loai 3');
    INSERT into CHATLIEU VALUES (N'cl005', N'Tre');
    INSERT into CHATLIEU VALUES (N'cl006', N'Nua');
    
    
    INSERT into NHOM VALUES (N'gr001', N'Ngoai that');
    INSERT into NHOM  VALUES (N'gr002', N'Noi that phong khách');
    INSERT into NHOM  VALUES (N'gr003', N'Noi that phong ngu');
    INSERT into NHOM  VALUES (N'gr004', N'Noi that phòng bep');
    INSERT into NHOM  VALUES (N'gr005', N'San go');
    INSERT into NHOM  VALUES (N'gr006', N'Do trang trí');
    
    
    INSERT into MAUSAC VALUES (N'ligthgreen', N'màu xanh sáng');
    INSERT into MAUSAC VALUES (N'oceangreen', N'mau xanh nuoc bien');
    INSERT into MAUSAC VALUES (N'creamwhite', N'màu kem');
    INSERT into MAUSAC VALUES (N'lemonyellow', N'màu vàng chanh');
    INSERT into MAUSAC VALUES (N'mediumyellow', N'màu vàng trung');
    INSERT into MAUSAC VALUES (N'orangeyellow', N'màu vàng cam');
    INSERT into MAUSAC VALUES (N'brown', N'màu nâu');
    INSERT into MAUSAC VALUES (N'lightsand', N'màu cát');
    INSERT into MAUSAC VALUES (N'sand', N'màu cát sáng');
    INSERT into MAUSAC VALUES (N'orche', N'màu dat son');
    INSERT into MAUSAC VALUES (N'wood', N'mau go');
    
    
    INSERT into BOPHAN VALUES (1, N'Quan ly',N' chinh thuc');
    INSERT into BOPHAN VALUES (2, N'Nhan vien quan ly kho',N' chinh thuc');
    INSERT into BOPHAN VALUES (3, N'Nhan vien ban hang',N' chinh thuc');
    INSERT into BOPHAN VALUES (4, N'Marketing',N' chinh thuc');
    
    
    INSERT into NHANVIEN VALUES (N'QL001', N'Nguyen Thuy Dung', N'Nu', N'0398874556',N'ThuyDung@gmail.com',1,15000000);
    INSERT into NHANVIEN VALUES (N'NV002', N'Le Thi Hoa',  N'Nu', N'0398874123',N'LeHoa@gmail.com',2,10000000) ;
    INSERT into NHANVIEN VALUES (N'NV003', N'Ly Thu Thu',  N'Nu', N'0398874112',N'ThuThug@gmail.com',3, 8000000);
    INSERT into NHANVIEN VALUES (N'NV004', N'Nguyen  Tan',  N'Nam', N'0398874113',N'TanNguyen@gmail.com',3,8000000);
    INSERT into NHANVIEN VALUES (N'NV005', N'Phan Van Anh',  N'Nam', N'0398874114',N'PhanAnh@gmail.com',3,7000000);
    INSERT into NHANVIEN VALUES (N'NV006', N'Tran Thi Thanh',  N'Nu', N'0398874115',N'ThanhThanh@gmail.com',3,8900000);
    INSERT into NHANVIEN VALUES (N'NV007', N'Truong Thu Nhu',  N'Nu', N'0398874116',N'TruongNhug@gmail.com',3,7300000);
    INSERT into NHANVIEN VALUES (N'NV008', N'Vo Thi Bao tran',  N'Nu', N'0398874117',N'BaoTran@gmail.com',2,7800000);
    INSERT into NHANVIEN VALUES (N'NV009', N'Tran nguc Hai',  N'Nam', N'0398874256',N'TranHain@gmail.com',2,6700000);
    INSERT into NHANVIEN VALUES (N'NV0010', N'Phan Van An',  N'Nam', N'0398874698',N'PhanAn@gmail.com',2,8500000);
    
    INSERT INTO KHACHHANG VALUES ('KH0001', 'Le Van My', '41 duong so 19, khu Phu My Hung, P.Tan Phu, Q.7, TP.HCM', '0838414567', 'LeVanMy@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0002', 'Pham Viet Anh', '1765A Dai Lo Binh Duong, P.Hiep An-Thu Dau 1, Tinh Binh Duong', '0838414567', 'VietAnh@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0003', 'Bui Thi Quynh Anh', '18 Lam Son, P.2, Q.Tan Binh, TP.HCM', '0838414567', 'QunhAnh@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0004', 'Vu Duc Anh', 'G4-22/1 Nguyen Thai Hoc, P.7, TP.Vung Tau', '0838414567', 'ThaiHOc@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0005', 'Nguyen Phung Linh Chi', '68 Ho Xuan Huong, Q.Ngu Hanh Son.TP.Da Nang', '0838414567', 'LinhChi@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0006', 'Duong My Dung', 'Dao Hon Tre, Vinh Nguyen, Nha Trang, tinh Khanh Hoa', '0838414567', 'MyDung@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0007', 'Nguyen Manh Duy', '23 Le Loi, Q.1, TP.HCM', '0838414567', 'ManhDuyy@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0008', 'Pham Phuong Duy', 'Bien Hoa, Dong Nai', '0838414567', 'Phuongduy@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0009', 'Nguyen Thuy Duong', '96 Vo Thi Sau, P.Tan Dinh, Q.1, TP.HCM', '0838414567', 'ThuyDuong@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0010', 'Luu Minh Hang', '25 Nguyen Van Linh, khu Phu My Hung, Q.7, TP.HCM', '0838414567', 'MinhHang@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0011', 'Nguyen Huu Minh Hoang', '41 duong so 19, khu Phu My Hung, P.Tan Phu, Q.7, TP.HCM', '0838414567', 'MinhHoang@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0012', 'Nguyen Duc Huy', '92 Nguyen Huu Canh, P.22, Q.Binh Tan', '0838414567', 'HuuCanh@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0013', 'Vu Duc Huy', 'P.Hoa Hai, Q.Ngu Hanh Son, TP.Da Nang', '0838414567', 'DucHuy@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0014', 'Nguyen Minh Khue', '23 Le Loi, Q.1,TP.HCM', '0838414567', 'MinhKhue@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0015', 'Nguyen Phuc Loc', ' duong so 2, Tang Nhon Phu B,TP.Thu Duc', '0838414567', 'PhucLoc@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0016', 'Trinh Xuan Minh', 'duong so 19, Tang Nhon Phu B,TP.Thu Duc', '0838414567', 'XuanTrinh@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0017', 'Hoang Kim Ngan', '120 Le Van Viet, TP.Thu Duc', '0838414567', 'KimNgan@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0018', 'Le Van Huong', 'duong so 12, Tang Nhon Phu B,TP.Thu Duc', '0838414963', 'VanHuong@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0019', 'Trinh Ai Dao', 'Nga 5 Chuong Cho, Go Vap', '0838414475', 'AiDao@gmail.com', 'Nu');
    INSERT INTO KHACHHANG VALUES ('KH0020', 'Luong kieu Anh', '78/11, Tran Xuan Soan, Quan 7', '0838414365', 'KieuAnh@gmail.com', 'Nu');
    INSERT INTO KHACHHANG VALUES ('KH0021', 'Ly Ngoc Hien', '102, Man Thien, TP.Thu Duc', '0838414354', 'NgocHien@gmail.com', 'Nu');
    INSERT INTO KHACHHANG VALUES ('KH0022', 'Bui Vinh Hien', '111 Tam Ha,TP.Thu Duc', '08384145215', 'VinhHien@gmail.com', 'Nam');
    INSERT INTO KHACHHANG VALUES ('KH0023', 'Trinh Kieu An', '11/45, Buon Me Thuot, DakLak', '0838414125', 'KieuAn@gmail.com', 'Nu');
    INSERT INTO KHACHHANG VALUES ('KH0024', 'Le Thi Hien', 'CuKuin, DaLak', '0838414598', 'HienLeh@gmail.com', 'Nu');
    INSERT INTO KHACHHANG VALUES ('KH0025', 'Le Van Loi', 'Buon Me Thuot, DakLak', '0335042136', 'VanLoi@gmail.com', 'Nam');


    INSERT INTO NHACUNGCAP VALUES ('CC001', 'Noi that Moc Viet', '106/1N duong Tan Hiep 17, ap Tan Thai 2, Hoc Mon, Tp. Ho Chi Minh', '0162595188', '093939657', 'noithatmocviet106@gmail.com');
    INSERT INTO NHACUNGCAP VALUES ('CC002', 'Noi that Truc Linh', 'So 51/97 Van Cao, Q. Ba Dinh, Ha Noi', '0903232317', '0903232311', 'info@truclinh.vn');
    INSERT INTO NHACUNGCAP VALUES ('CC003', 'Noi that Minh Tien', 'Tang 9, Toa nha So Cong Thuong, 163 Hai Ba Trung, Phuong 6, Quan 3, Tp. Ho Chi', '0139118383', '39118385', 'minhtien@mtic.vn');
    INSERT INTO NHACUNGCAP VALUES ('CC004', 'Noi that Dai Phat', 'So 18, duong So 9, To 74, Khu Pho 3, P. Trung Mau Tay, Q. 12, Tp. Ho Chi Minh', '0162576254', '62576255', 'daiphat26@gmail.com');
    INSERT INTO NHACUNGCAP VALUES ('CC005', 'Thiet Ke Noi that Nam Ha', 'TDP Dai Cao, TT. Hop Chau, H. Tam Dao, Vanh Phuc', '0972239368', '0975288106', 'noithatnamha.68@gmail.com');    
       
    INSERT INTO SANPHAM VALUES ('NT001', 'Ban ngoai troi YO', 100, 5000000, 'hang Noi nhap', 'gr001', 'cl001', 'sand');
    INSERT INTO SANPHAM VALUES ('NT002', 'Ghe ngoai troi Angela Alu', 120, 250000, 'hang Noi nhap', 'gr001', 'cl001', 'oceangreen');
    INSERT INTO SANPHAM VALUES ('NT003', 'Ghe ngoai troi Tuka boc vai Samoa SQB', 110, 3500000, 'hang Noi nhap', 'gr001', 'cl001', 'creamwhite');
    INSERT INTO SANPHAM VALUES ('NT004', 'Ghe xep Lorette Lagoon blue 570146', 60, 100000, 'hang Noi nhap', 'gr001', 'cl001', 'orangeyellow');
    INSERT INTO SANPHAM VALUES ('NT005', 'Ban ben Stulle CB5209-P E P7L/P97W', 70, 1500000, 'hang Noi nhap', 'gr002', 'cl001', 'brown');
    INSERT INTO SANPHAM VALUES ('NT006', 'Ban ben Stulle P98W', 70, 1400000, 'hang Noi nhap', 'gr002', 'cl001', 'brown');
    INSERT INTO SANPHAM VALUES ('NT007', 'Ban ngoai troi Easy mau saffron', 100, 4500000, 'hang Noi nhap', 'gr001', 'cl001', 'brown');
    INSERT INTO SANPHAM VALUES ('NT008', 'Ghe tua nang Alize Xs Nutmeg', 100, 600000, 'hang Noi nhap', 'gr001', 'cl001', 'brown');
    INSERT INTO SANPHAM VALUES ('NT009', 'Ban ngoai troi Fermob Sixties', 80, 3600000, 'hang Noi nhap', 'gr001', 'cl001', 'sand');
    INSERT INTO SANPHAM VALUES ('NT0010', 'Ghe dai 3 cho', 50, 400000, 'hang Noi nhap', 'gr001', 'cl001', 'brown');
    
    INSERT INTO SANPHAM VALUES ('PK001', 'Ban nuoc May - 2 Modul', 50, 3000000, 'hang Noi nhap', 'gr002', 'cl005', 'brown');
    INSERT INTO SANPHAM VALUES ('PK002', 'Ban ben Osaka', 50, 3000000, 'hang Noi nhap', 'gr002', 'cl001', 'brown');
    INSERT INTO SANPHAM VALUES ('PK003', 'Ke sach Osaka', 50, 700000, 'hang Noi nhap', 'gr002', 'cl001', 'orangeyellow');
    INSERT INTO SANPHAM VALUES ('PK004', 'Tuong con chim go lon 21847', 50, 600000, 'hang Noi nhap', 'gr002', 'cl001', 'lemonyellow');
    INSERT INTO SANPHAM VALUES ('PK005', 'Sofa Miami 2 cho hien dai voi xanh', 50, 3400000, 'hang Noi nhap', 'gr002', 'cl001', 'lightsand');
    INSERT INTO SANPHAM VALUES ('PK006', 'Ban nuoc Rumba', 40, 4000000, 'hang Noi nhap', 'gr002', 'cl002', 'lightsand');
    INSERT INTO SANPHAM VALUES ('PK007', 'Tu tivi Elegance mau tu nhien', 55, 4000000, 'hang Noi nhap', 'gr002', 'cl001', 'wood');
    INSERT INTO SANPHAM VALUES ('PK008', 'Ban nuoc Elegance mau tu nhien', 70, 5000000, 'hang Noi nhap', 'gr002', 'cl001', 'brown');
    INSERT INTO SANPHAM VALUES ('PK009', 'Ke sach Division F – mau Trang', 50, 700000, 'hang Noi nhap', 'gr002', 'cl001', 'wood');
    INSERT INTO SANPHAM VALUES ('PK0010', 'Ban nuoc Thin', 100, 1400000, 'hang Noi nhap', 'gr002', 'cl003', 'brown');
    INSERT INTO SANPHAM VALUES ('PN001', 'Ban Console Addict', 50, 1800000, 'hang Noi nhap', 'gr003', 'cl002', 'wood');
    INSERT INTO SANPHAM VALUES ('PN002', 'Ban dau giuong Cabo PMA532058 F1', 40, 1400000, 'hang Noi nhap', 'gr003', 'cl006', 'creamwhite');
    INSERT INTO SANPHAM VALUES ('PN003', 'Giuong Cabo 1m8 PMA940025', 30, 1200000, 'hang Noi nhap', 'gr001', 'cl001', 'wood');
    INSERT INTO SANPHAM VALUES ('PN004', 'Ban trang diem May - mau 2', 100, 2300000, 'hang Noi nhap', 'gr003', 'cl005', 'orche');
    INSERT INTO SANPHAM VALUES ('PN005', 'Tu ao Maxine', 100, 1400000, 'hang Noi nhap', 'gr003', 'cl001', 'orangeyellow');
    INSERT INTO SANPHAM VALUES ('PN006', 'Ban dau giuong Maxine', 100, 1400000, 'hang Noi nhap', 'gr003', 'cl003', 'mediumyellow');
    INSERT INTO SANPHAM VALUES ('PN007', 'Giuong ngu boc voi Skagen 1m6 mau', 100, 1900000, 'hang Noi nhap', 'gr003', 'cl001', 'wood');
    INSERT INTO SANPHAM VALUES ('PN008', 'Ban dau giuong Skagen ben trai', 100, 1300000, 'hang Noi nhap', 'gr003', 'cl003', 'ligthgreen');
    INSERT INTO SANPHAM VALUES ('TT001', 'Bang treo chia khoa', 80, 300000, 'hang Noi nhap', 'gr006', 'cl006', 'mediumyellow');
    INSERT INTO SANPHAM VALUES ('TT002', 'Binh Aline xanh XS 16x16x16 23102J', 80, 300000, 'hang Noi nhap', 'gr006', 'cl001', 'ligthgreen');
    INSERT INTO SANPHAM VALUES ('TT003', 'Binh con buom 60464K', 80, 400000, 'hang Noi nhap', 'gr006', 'cl001', 'orangeyellow');
    INSERT INTO SANPHAM VALUES ('TT004', 'Bo hai chan nen Orche 10x30 29078J', 80, 400000, 'hang Noi nhap', 'gr006', 'cl001', 'orche');
    INSERT INTO SANPHAM VALUES ('TT005', 'Chau hoa rung go nau vua 16x16x14 22775', 80, 900000, 'hang Noi nhap', 'gr006', 'cl001', 'wood');
    INSERT INTO SANPHAM VALUES ('PB001', 'Ban an 1m8 Elegance mau nau', 100, 7400000, 'hang Noi nhap', 'gr004', 'cl001', 'oceangreen');
    INSERT INTO SANPHAM VALUES ('PB002', 'Ghe an co tay Elegance mau nau', 90, 240000, 'hang Noi nhap', 'gr004', 'cl001', 'orche');
    INSERT INTO SANPHAM VALUES ('PB003', 'Bench Elegance mau nau da Cognac', 50, 5400000, 'hang Noi nhap', 'gr004', 'cl002', 'brown');
    INSERT INTO SANPHAM VALUES ('PB004', 'Tu Ruou Gujilow 410071Z', 50, 14000000, 'hang Noi nhap', 'gr004', 'cl001', 'sand');
    INSERT INTO SANPHAM VALUES ('PB005', 'Xe day do an Giro', 40, 1400000, 'hang Noi nhap', 'gr004', 'cl001', 'oceangreen');
    INSERT INTO SANPHAM VALUES ('PB006', 'Ban an 1m8 Elegance mau tu nhien', 50, 9400000, 'hang Noi nhap', 'gr004', 'cl001', 'orche');
    INSERT INTO SANPHAM VALUES ('PB007', 'Ghe an co tay Elegance mau tu nhien', 100, 3100000, 'hang Noi nhap', 'gr004', 'cl001', 'brown');
    INSERT INTO SANPHAM VALUES ('PB008', 'Bench Elegance mau tu nhien da cognac', 80, 4400000, 'hang Noi nhap', 'gr004', 'cl002', 'brown');
            
        
        
    INSERT INTO NHAPHANG VALUES ('NH001', TO_DATE('2023-03-01', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH002', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH003', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH004', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH005', TO_DATE('2023-01-01', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH006', TO_DATE('2023-02-01', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH007', TO_DATE('2023-02-07', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH008', TO_DATE('2023-02-01', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH009', TO_DATE('2023-02-05', 'YYYY-MM-DD'), 'NV002', 'CC001');
    INSERT INTO NHAPHANG VALUES ('NH0010', TO_DATE('2023-02-05', 'YYYY-MM-DD'), 'NV002', 'CC001');
    
    INSERT INTO CTNHAPHANG VALUES ( 'NT001', 'NH001', 100);
    INSERT INTO CTNHAPHANG VALUES ( 'NT002', 'NH002', 120);
    INSERT INTO CTNHAPHANG VALUES ( 'NT003', 'NH003', 110);
    INSERT INTO CTNHAPHANG VALUES ( 'NT004', 'NH004', 60);
    INSERT INTO CTNHAPHANG VALUES ( 'NT005', 'NH005', 70);
    INSERT INTO CTNHAPHANG VALUES ('NT006', 'NH006', 70);
    INSERT INTO CTNHAPHANG VALUES ( 'NT007', 'NH007', 100);
    INSERT INTO CTNHAPHANG VALUES ('NT008', 'NH008', 100);
    INSERT INTO CTNHAPHANG VALUES ('NT009', 'NH009', 80);
    INSERT INTO CTNHAPHANG VALUES ( 'NT0010', 'NH0010', 50);   
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK001', 'NH001', 50);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK002', 'NH002', 50);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK003', 'NH003', 50);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK004', 'NH004', 50);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK005', 'NH005', 50);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK006', 'NH006', 40);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK007', 'NH007', 55);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK008', 'NH008', 70);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK009', 'NH009', 50);
    INSERT INTO CTNHAPHANG (MASP, MANHAPHANG, SOLUONG) VALUES ('PK0010', 'NH0010', 60);
    
    INSERT INTO HOADON VALUES ('HD001', TO_DATE('2022-10-01', 'YYYY-MM-DD'),37000000,  'NV003', 'KH0001');
    INSERT INTO HOADON VALUES ('HD002', TO_DATE('2022-10-06', 'YYYY-MM-DD'),1900000, 'NV003', 'KH0002');
    INSERT INTO HOADON VALUES ('HD003', TO_DATE('2022-12-06', 'YYYY-MM-DD'),5750000, 'NV003', 'KH0003');
    INSERT INTO HOADON VALUES ('HD004', TO_DATE('2022-12-17', 'YYYY-MM-DD'),14100000, 'NV003', 'KH0004');
    INSERT INTO HOADON VALUES ('HD005', TO_DATE('2023-02-22', 'YYYY-MM-DD'),8800000,  'NV003', 'KH0005');
    INSERT INTO HOADON VALUES ('HD006', TO_DATE('2023-03-28', 'YYYY-MM-DD'),12600000,  'NV004', 'KH0006');
    INSERT INTO HOADON VALUES ('HD007', TO_DATE('2023-03-13', 'YYYY-MM-DD'),20800000,  'NV004', 'KH0007');
    INSERT INTO HOADON VALUES ('HD008', TO_DATE('2023-03-15', 'YYYY-MM-DD'),19000000,  'NV005', 'KH0008');
    INSERT INTO HOADON VALUES ('HD009', TO_DATE('2023-03-09', 'YYYY-MM-DD'),7200000,  'NV005', 'KH0009');
    INSERT INTO HOADON VALUES ('HD010', TO_DATE('2023-04-08', 'YYYY-MM-DD'),7500000,  'NV006', 'KH0010');
    INSERT INTO HOADON VALUES ('HD011', TO_DATE('2023-04-14', 'YYYY-MM-DD'),5000000,  'NV006', 'KH0011');
    INSERT INTO HOADON VALUES ('HD012', TO_DATE('2023-04-13', 'YYYY-MM-DD'),5000000, 'NV007', 'KH0012');
    INSERT INTO HOADON VALUES ('HD013', TO_DATE('2023-04-15', 'YYYY-MM-DD'),7900000,  'NV007', 'KH0013');
    INSERT INTO HOADON VALUES ('HD014', TO_DATE('2023-04-11', 'YYYY-MM-DD'),7500000,  'NV004', 'KH0014');
    INSERT INTO HOADON VALUES ('HD015', TO_DATE('2023-04-03', 'YYYY-MM-DD'),16400000,  'NV003', 'KH0015');
    
    INSERT INTO HOADON VALUES ('HD016', TO_DATE('2023-05-03', 'YYYY-MM-DD'),25200000,  'NV005', 'KH0006');
    INSERT INTO HOADON VALUES ('HD017', TO_DATE('2023-06-03', 'YYYY-MM-DD'),9400000,  'NV003', 'KH0009');
    INSERT INTO HOADON VALUES ('HD018', TO_DATE('2023-08-03', 'YYYY-MM-DD'),15400000,  'NV005', 'KH0010');
    INSERT INTO HOADON VALUES ('HD019', TO_DATE('2023-10-03', 'YYYY-MM-DD'),25400000,  'NV004', 'KH0011');
    INSERT INTO HOADON VALUES ('HD020', TO_DATE('2023-11-03', 'YYYY-MM-DD'),9100000,  'NV007', 'KH0003');
    

    INSERT INTO CTHOADON VALUES ('HD001', 'PN001', 5, 1800000);
    INSERT INTO CTHOADON VALUES ('HD001', 'PN002', 10, 1400000);
    INSERT INTO CTHOADON VALUES ('HD001', 'PN006', 10, 1400000);
    INSERT INTO CTHOADON VALUES ('HD002', 'PN007', 10, 190000);
    INSERT INTO CTHOADON VALUES ('HD002', 'PN009', 10, 540000);
    INSERT INTO CTHOADON VALUES ('HD003', 'PB005', 3, 1400000);
    INSERT INTO CTHOADON VALUES ('HD003', 'PB007', 5, 310000);
    INSERT INTO CTHOADON VALUES ('HD004', 'PB006', 15, 940000);
    INSERT INTO CTHOADON VALUES ('HD005', 'PB008', 2, 4400000);
    INSERT INTO CTHOADON VALUES ('HD006', 'PB004', 9, 1400000);
    INSERT INTO CTHOADON VALUES ('HD007', 'PB007', 4, 3100000);
    INSERT INTO CTHOADON VALUES ('HD007', 'PN002', 6, 1400000);
    INSERT INTO CTHOADON VALUES ('HD008', 'TT001', 10, 300000);
    INSERT INTO CTHOADON VALUES ('HD008', 'TT002', 20, 300000);
    INSERT INTO CTHOADON VALUES ('HD008', 'TT003', 10, 400000);
    INSERT INTO CTHOADON VALUES ('HD008', 'TT004', 15, 400000);
    INSERT INTO CTHOADON VALUES ('HD009', 'PN003', 6, 1200000);
    INSERT INTO CTHOADON VALUES ('HD010', 'NT002', 3, 2500000);
    INSERT INTO CTHOADON VALUES ('HD011', 'NT004', 5, 1000000);
    INSERT INTO CTHOADON VALUES ('HD012', 'NT002', 2, 2500000);
    INSERT INTO CTHOADON VALUES ('HD013', 'PB007', 1, 3100000);
    INSERT INTO CTHOADON VALUES ('HD013', 'TT004', 12, 400000);
    INSERT INTO CTHOADON VALUES ('HD014', 'NT002', 3, 2500000);
    INSERT INTO CTHOADON VALUES ('HD015', 'PB006', 1, 9400000);
    INSERT INTO CTHOADON VALUES ('HD015', 'PN006', 5, 1400000);
    
    INSERT INTO CTHOADON VALUES ('HD016', 'PB006', 1, 9400000);
    INSERT INTO CTHOADON VALUES ('HD016', 'PB008', 2, 4400000);
    INSERT INTO CTHOADON VALUES ('HD006', 'PB006', 15, 940000);
    INSERT INTO CTHOADON VALUES ('HD016', 'PN006', 5, 1400000);
    INSERT INTO CTHOADON VALUES ('HD017', 'PB006', 1, 9400000);
    INSERT INTO CTHOADON VALUES ('HD018', 'PN006', 5, 1400000);
    INSERT INTO CTHOADON VALUES ('HD018', 'PN009', 10, 540000);
    INSERT INTO CTHOADON VALUES ('HD018', 'PN002', 6, 1400000);
    INSERT INTO CTHOADON VALUES ('HD019', 'PN001', 5, 1800000);
    INSERT INTO CTHOADON VALUES ('HD019', 'PN006', 5, 1400000);
    INSERT INTO CTHOADON VALUES ('HD019', 'PB006', 1, 9400000);
    INSERT INTO CTHOADON VALUES ('HD020', 'PB007', 1, 3100000);
    INSERT INTO CTHOADON VALUES ('HD020', 'TT002', 20, 300000);
    
    
    INSERT INTO BAOCAODOANHTHUTHANG VALUES ('BC001', 'Bao cao doanh thu ', 10,2022,38900000);
    INSERT INTO BAOCAODOANHTHUTHANG VALUES ('BC002', 'Bao cao doanh thu ', 11,2022,19850000);
    INSERT INTO BAOCAODOANHTHUTHANG VALUES ('BC003', 'Bao cao doanh thu ', 2,2023,8800000);
    INSERT INTO BAOCAODOANHTHUTHANG VALUES ('BC004', 'Bao cao doanh thu ', 3,2023,73700000);
    INSERT INTO BAOCAODOANHTHUTHANG VALUES ('BC005', 'Bao cao doanh thu ', 4,2023,49300000);
    INSERT INTO BAOCAODOANHTHUTHANG VALUES ('BC006', 'Bao cao doanh thu ', 5,2023,25200000);
    


  