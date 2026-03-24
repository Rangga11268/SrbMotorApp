# API REFERENCE - SRB MOTOR

**Version**: 1.0  
**Last Updated**: March 19, 2026  
**Framework**: Laravel 12 (Inertia.js)  
**Authentication**: Laravel Session + JWT (for mobile)

---

## 📌 Base URL

```
Development:  http://localhost:8000
Production:   https://api.srbmotor.com  (update accordingly)
```

---

## 🔐 Authentication

### Session-Based (Web)

```
Login → Laravel Session Cookie → All subsequent requests include cookie
```

### Token-Based (Mobile/API)

```
Header: Authorization: Bearer <JWT-TOKEN>
```

### OTP Verification

```
POST /login → OTP sent → POST /verify-otp → JWT token return
```

---

## 📚 API ENDPOINTS

### 1. AUTHENTICATION

#### POST `/login`

**Public** - User Login

```
Request:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "status": "success",
  "message": "Login berhasil",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "John Doe",
    "role": "user"
  }
}

Error (401):
{
  "status": "error",
  "message": "Email atau password salah"
}
```

#### POST `/register`

**Public** - User Registration

```
Request:
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "password_confirmation": "password123"
}

Response (201):
{
  "status": "success",
  "message": "Registrasi berhasil",
  "data": {
    "id": 2,
    "email": "john@example.com",
    "name": "John Doe"
  }
}

Validation Error (422):
{
  "status": "error",
  "message": "Validation failed",
  "errors": {
    "email": ["Email sudah terdaftar"]
  }
}
```

#### POST `/logout`

**Protected** - User Logout

```
Headers: Authorization: Bearer <token>

Response (200):
{
  "status": "success",
  "message": "Logout berhasil"
}
```

---

### 2. MOTORS

#### GET `/api/search/motors`

**Public** - Search & Filter Motors

```
Query Parameters:
  - q: string (search keyword)
  - category_id: int (filter by category)
  - min_price: int (filter minimum price)
  - max_price: int (filter maximum price)
  - brand: string (filter by brand)
  - sort: string (sort field: price, created_at, name)
  - order: string (asc, desc)
  - page: int (pagination)
  - per_page: int (items per page)

Example: GET /api/search/motors?q=aerox&brand=yamaha&sort=price&order=asc

Response (200):
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "name": "Yamaha Aerox",
      "brand": "Yamaha",
      "model": "155 ABS",
      "price": 29500000,
      "image_path": "/storage/motors/aerox.jpg",
      "details": "Skuter matik modern dengan teknologi ABS...",
      "tersedia": true,
      "created_at": "2026-03-19T10:30:00Z"
    }
  ],
  "meta": {
    "total": 15,
    "per_page": 10,
    "page": 1,
    "last_page": 2
  }
}
```

#### GET `/motors/{motor}`

**Public** - Get Motor Detail

```
Example: GET /motors/1

Response (200):
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "Yamaha Aerox",
    "brand": "Yamaha",
    "model": "155 ABS",
    "price": 29500000,
    "year": 2024,
    "type": "Automatic",
    "image_path": "/storage/motors/aerox.jpg",
    "details": "Skuter matik modern dengan teknologi ABS...",
    "tersedia": true,
    "category": {
      "id": 2,
      "name": "Skuter Matik"
    },
    "financing_options": [
      {
        "tenor": 12,
        "monthly_payment": 2875000,
        "total": 34500000,
        "leasing_provider": "Astra Credit"
      },
      {
        "tenor": 24,
        "monthly_payment": 1580000,
        "total": 37920000,
        "leasing_provider": "Astra Credit"
      }
    ],
    "reviews": [
      {
        "user": "Budi",
        "rating": 5,
        "comment": "Bagus banget, responsif!",
        "created_at": "2026-03-10T00:00:00Z"
      }
    ],
    "rating_average": 4.5,
    "review_count": 12
  }
}
```

---

### 3. ORDERS (TRANSACTIONS)

#### POST `/motors/{motor}/process-cash-order`

**Protected** - Create Cash Order

```
Headers: Authorization, Content-Type: application/json

Request Body:
{
  "customer_name": "Budi Santoso",
  "customer_phone": "+6281234567890",
  "customer_occupation": "Karyawan",
  "address": "Jl. Merdeka No. 123",
  "notes": "Tolong siapkan sedini mungkin"
}

Response (201):
{
  "status": "success",
  "message": "Pesanan berhasil dibuat",
  "data": {
    "id": 101,
    "reference_number": "ORD-2026031901001",
    "transaction_type": "CASH",
    "status": "new_order",
    "motor": {
      "id": 1,
      "name": "Yamaha Aerox"
    },
    "total_price": 29500000,
    "customer_name": "Budi Santoso",
    "created_at": "2026-03-19T10:30:00Z"
  }
}

Validation Error (422):
{
  "status": "error",
  "message": "Validasi gagal",
  "errors": {
    "customer_phone": ["Nomor telepon tidak valid"]
  }
}
```

#### POST `/motors/{motor}/process-credit-order`

**Protected** - Create Credit Order

```
Headers: Authorization, Content-Type: application/json

Request Body:
{
  "customer_name": "Budi Santoso",
  "customer_phone": "+6281234567890",
  "customer_occupation": "Karyawan",
  "address": "Jl. Merdeka No. 123",
  "birth_date": "1990-03-19",
  "gender": "L",
  "nik": "3278012345678901",
  "tenor": 12,
  "down_payment": 5000000,
  "leasing_provider_id": 1
}

Response (201):
{
  "status": "success",
  "message": "Pesanan kredit berhasil dibuat",
  "data": {
    "id": 102,
    "reference_number": "ORD-2026031901002",
    "transaction_type": "CREDIT",
    "status": "new_order",
    "motor": {
      "id": 1,
      "name": "Yamaha Aerox"
    },
    "credit_detail": {
      "id": 50,
      "down_payment": 5000000,
      "tenor": 12,
      "monthly_installment": 2416666.67,
      "credit_status": "menunggu_persetujuan"
    },
    "created_at": "2026-03-19T10:30:00Z"
  }
}
```

#### GET `/motors/transactions/{transaction}`

**Protected** - Get Order Status

```
Headers: Authorization

Example: GET /motors/transactions/101

Response (200):
{
  "status": "success",
  "data": {
    "id": 101,
    "reference_number": "ORD-2026031901001",
    "transaction_type": "CASH",
    "status": "payment_confirmed",
    "motor": {
      "id": 1,
      "name": "Yamaha Aerox"
    },
    "customer_name": "Budi Santoso",
    "total_price": 29500000,
    "payment_status": "confirmed",
    "payment_date": "2026-03-19T14:20:00Z",
    "timeline": [
      {
        "stage": 1,
        "name": "Pesanan Diterima",
        "completed_at": "2026-03-19T10:30:00Z",
        "status": "completed"
      },
      {
        "stage": 2,
        "name": "Tunggu Pembayaran",
        "completed_at": null,
        "status": "in_progress"
      },
      {
        "stage": 3,
        "name": "Pembayaran Terkonfirmasi",
        "completed_at": "2026-03-19T14:20:00Z",
        "status": "completed"
      },
      {
        "stage": 4,
        "name": "Persiapan Unit",
        "completed_at": null,
        "status": "pending"
      }
    ]
  }
}
```

#### POST `/motors/{transaction}/upload-credit-documents`

**Protected** - Upload Credit Documents

```
Headers: Authorization, Content-Type: multipart/form-data

Request Body (multi-part):
{
  "ktp": <File>,
  "slip_gaji": <File>,
  "bank_statement": <File>,
  "selfie": <File>
}

Response (200):
{
  "status": "success",
  "message": "Dokumen berhasil diupload",
  "data": {
    "documents": [
      {
        "id": 1,
        "credit_detail_id": 50,
        "document_type": "KTP",
        "file_path": "/storage/documents/ktp_user_1_20260319.jpg",
        "uploaded_at": "2026-03-19T10:40:00Z"
      }
    ]
  }
}

Error (422):
{
  "status": "error",
  "message": "Upload gagal",
  "errors": {
    "ktp": ["File harus berupa image (jpg, png)"]
  }
}
```

#### POST `/motors/{transaction}/cancel`

**Protected** - Cancel Order

```
Headers: Authorization, Content-Type: application/json

Request Body:
{
  "reason": "Urgensi biaya berkurang"
}

Response (200):
{
  "status": "success",
  "message": "Pesanan berhasil dibatalkan"
}
```

---

### 4. INSTALLMENTS

#### GET `/installments`

**Protected** - List Installments

```
Headers: Authorization

Query Parameters:
  - status: string (pending, paid, overdue)
  - sort: string (due_date)
  - order: string (asc, desc)

Response (200):
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "transaction_id": 102,
      "installment_number": 0,
      "amount": 5000000,
      "due_date": "2026-04-19",
      "status": "pending",
      "paid_at": null,
      "transaction": {
        "reference_number": "ORD-2026031901002",
        "motor_name": "Yamaha Aerox"
      }
    },
    {
      "id": 2,
      "transaction_id": 102,
      "installment_number": 1,
      "amount": 2416666.67,
      "due_date": "2026-05-19",
      "status": "pending",
      "paid_at": null
    }
  ]
}
```

#### POST `/installments/{installment}/pay`

**Protected** - Confirm Cash Payment

```
Headers: Authorization, Content-Type: multipart/form-data

Request Body:
{
  "payment_proof": <File>,
  "notes": "Sudah transfer ke BCA"
}

Response (200):
{
  "status": "success",
  "message": "Pembayaran tercatat, menunggu verifikasi admin"
}
```

#### POST `/installments/{installment}/pay-online`

**Protected** - Initiate Online Payment (Midtrans)

```
Headers: Authorization

Response (200):
{
  "status": "success",
  "data": {
    "snap_token": "12ea98d234jsd...",
    "payment_url": "https://app.midtrans.com/snap/v2/...",
    "redirect_url": "/checkout?snap_token=..."
  }
}
```

#### POST `/midtrans/notification`

**Public** - Midtrans Payment Callback

```
Triggered automatically by Midtrans server
Request Body (from Midtrans):
{
  "transaction_id": "...",
  "order_id": "...",
  "payment_type": "bank_transfer",
  "transaction_status": "settlement",
  "settlement_time": "2026-03-19 12:00:00",
  "signature_key": "..."
}

Internal Processing:
- Update installment.status = 'paid'
- Update installment.paid_at = settlement_time
- Send notification to user & admin
- Check if all installments paid

Response (200):
{
  "status": "success"
}
```

---

### 5. USER PROFILE

#### GET `/profile`

**Protected** - Get User Profile

```
Headers: Authorization

Response (200):
{
  "status": "success",
  "data": {
    "id": 1,
    "name": "Budi Santoso",
    "email": "budi@example.com",
    "phone": "+6281234567890",
    "role": "user",
    "profile": {
      "nik": "3278012345678901",
      "tanggal_lahir": "1990-03-19",
      "jenis_kelamin": "L",
      "alamat": "Jl. Merdeka No. 123",
      "pekerjaan": "Karyawan"
    },
    "created_at": "2026-01-15T10:00:00Z"
  }
}
```

#### PUT `/profile`

**Protected** - Update Profile

```
Headers: Authorization, Content-Type: application/json

Request Body:
{
  "name": "Budi Santoso",
  "phone": "+6281234567890",
  "tanggal_lahir": "1990-03-19",
  "jenis_kelamin": "L",
  "alamat": "Jl. Merdeka No. 123",
  "pekerjaan": "Karyawan"
}

Response (200):
{
  "status": "success",
  "message": "Profil berhasil diperbarui"
}
```

#### PUT `/profile/password`

**Protected** - Change Password

```
Headers: Authorization, Content-Type: application/json

Request Body:
{
  "current_password": "old123",
  "new_password": "new456",
  "new_password_confirmation": "new456"
}

Response (200):
{
  "status": "success",
  "message": "Password berhasil diubah"
}

Error (422):
{
  "status": "error",
  "message": "Password lama tidak sesuai"
}
```

---

### 6. NEWS/POSTS

#### GET `/berita`

**Public** - List News/Posts

```
Query Parameters:
  - category_id: int (filter by category)
  - search: string (search keyword)
  - sort: string (created_at, title)
  - order: string (asc, desc)
  - page: int (pagination)
  - per_page: int (items per page)

Response (200):
{
  "status": "success",
  "data": [
    {
      "id": 1,
      "title": "Tips Merawat Motor Matic",
      "slug": "tips-merawat-motor-matic",
      "content": "Lorem ipsum dolor sit amet...",
      "category": {
        "id": 1,
        "name": "Tips & Trik"
      },
      "created_by": "Admin",
      "created_at": "2026-03-15T10:00:00Z"
    }
  ]
}
```

#### GET `/berita/{post:slug}`

**Public** - Get Post Detail

```
Example: GET /berita/tips-merawat-motor-matic

Response (200):
{
  "status": "success",
  "data": {
    "id": 1,
    "title": "Tips Merawat Motor Matic",
    "slug": "tips-merawat-motor-matic",
    "content": "Lorem ipsum dolor sit amet...",
    "category": {
      "id": 1,
      "name": "Tips & Trik"
    },
    "created_by": "Admin",
    "created_at": "2026-03-15T10:00:00Z"
  }
}
```

---

### 7. ADMIN DASHBOARD

#### GET `/admin`

**Admin Protected** - Admin Dashboard

```
Headers: Authorization, Role: admin

Response (200):
{
  "status": "success",
  "data": {
    "total_users": 150,
    "total_revenue": 5000000000,
    "pending_approvals": 8,
    "total_transactions": 320,
    "recent_transactions": [
      {
        "id": 102,
        "reference_number": "ORD-20260319...",
        "customer_name": "Budi Santoso",
        "motor_name": "Yamaha Aerox",
        "transaction_type": "CREDIT",
        "status": "menunggu_persetujuan",
        "total_price": 29500000,
        "created_at": "2026-03-19T10:30:00Z"
      }
    ]
  }
}
```

---

### 8. ADMIN CREDIT MANAGEMENT

#### GET `/admin/credits`

**Admin Protected** - List Credit Applications

```
Headers: Authorization, Role: admin

Query Parameters:
  - status: string (menunggu_persetujuan, disetujui, ditolak)
  - sort: string (created_at, total_price)
  - order: string (asc, desc)
  - page: int (pagination)

Response (200):
{
  "status": "success",
  "data": [
    {
      "id": 50,
      "transaction_id": 102,
      "customer_name": "Budi Santoso",
      "motor_name": "Yamaha Aerox",
      "motor_price": 29500000,
      "down_payment": 5000000,
      "tenor": 12,
      "monthly_installment": 2416666.67,
      "credit_status": "menunggu_persetujuan",
      "documents_verified": false,
      "created_at": "2026-03-19T10:30:00Z"
    }
  ]
}
```

#### GET `/admin/credits/{credit}`

**Admin Protected** - Get Credit Detail & Documents

```
Headers: Authorization, Role: admin

Response (200):
{
  "status": "success",
  "data": {
    "id": 50,
    "transaction": {
      "id": 102,
      "reference_number": "ORD-...",
      "customer_name": "Budi Santoso",
      "customer_phone": "+6281234567890"
    },
    "credit_detail": {
      "down_payment": 5000000,
      "tenor": 12,
      "monthly_installment": 2416666.67,
      "credit_status": "menunggu_persetujuan"
    },
    "documents": [
      {
        "id": 1,
        "document_type": "KTP",
        "file_path": "/storage/documents/...",
        "verified_at": null,
        "verified_by": null
      }
    ]
  }
}
```

#### POST `/admin/credits/{credit}/verify-documents`

**Admin Protected** - Approve All Documents

```
Headers: Authorization, Role: admin, Content-Type: application/json

Request Body:
{
  "notes": "Dokumen lengkap dan sesuai standar"
}

Response (200):
{
  "status": "success",
  "message": "Dokumen terverifikasi"
}
```

#### POST `/admin/credits/{credit}/reject-document`

**Admin Protected** - Reject Document

```
Headers: Authorization, Role: admin, Content-Type: application/json

Request Body:
{
  "document_id": 1,
  "rejection_reason": "Foto KTP tidak jelas"
}

Response (200):
{
  "status": "success",
  "message": "Dokumen ditolak"
}
```

#### POST `/admin/credits/{credit}/approve`

**Admin Protected** - Approve Credit

```
Headers: Authorization, Role: admin, Content-Type: application/json

Request Body:
{
  "approved_amount": 24500000,
  "notes": "Disetujui sesuai rekomendasi surveyor"
}

Response (200):
{
  "status": "success",
  "message": "Kredit berhasil disetujui",
  "data": {
    "credit_status": "disetujui"
  }
}
```

#### POST `/admin/credits/{credit}/reject`

**Admin Protected** - Reject Credit

```
Headers: Authorization, Role: admin, Content-Type: application/json

Request Body:
{
  "rejection_reason": "Pendapatan kurang memenuhi syarat"
}

Response (200):
{
  "status": "success",
  "message": "Kredit ditolak"
}
```

---

## 🔍 Error Handling

### Common Error Codes

| Code | Message           | Solution                          |
| ---- | ----------------- | --------------------------------- |
| 400  | Bad Request       | Check request parameters & format |
| 401  | Unauthorized      | Login first or use valid token    |
| 403  | Forbidden         | User doesn't have permission      |
| 404  | Not Found         | Resource doesn't exist            |
| 422  | Validation Failed | Check errors in response          |
| 429  | Too Many Requests | Rate limited - wait before retry  |
| 500  | Server Error      | Contact support                   |

### Error Response Format

```json
{
    "status": "error",
    "message": "Human-readable error message",
    "errors": {
        "field_name": ["Error description"]
    }
}
```

---

## 🔄 Pagination

```
Query Parameters:
  - page: int (default: 1)
  - per_page: int (default: 10, max: 100)

Response Meta:
{
  "meta": {
    "total": 150,
    "per_page": 10,
    "current_page": 1,
    "last_page": 15,
    "from": 1,
    "to": 10,
    "path": "http://localhost:8000/api/motors"
  }
}
```

---

## 🎯 Rate Limiting

| Endpoint        | Limit | Window   |
| --------------- | ----- | -------- |
| `/login`        | 5     | 1 minute |
| `/register`     | 3     | 1 hour   |
| `/orders/*`     | 15    | 1 minute |
| Other endpoints | 60    | 1 minute |

---

## 📝 Response Format

All responses follow consistent format:

```json
{
    "status": "success|error",
    "message": "Human readable message",
    "data": {},
    "meta": {}
}
```

---

**Last Updated**: March 19, 2026  
**Status**: 🟢 Complete & Ready  
**Contact**: Backend Team
