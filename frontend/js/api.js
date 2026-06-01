// Tự động nhận diện môi trường: localhost dùng Spring Boot port 8080, production dùng relative path
const BASE_URL = window.location.origin.includes('localhost')
  ? 'http://localhost:8080/api'
  : '/api';

const TOKEN_KEY = 'auth_token';

// Class đại diện cho lỗi từ API, chứa mã HTTP status và dữ liệu lỗi trả về từ server
export class ApiError extends Error {
  constructor(message, status, data) {
    super(message);
    this.name = 'ApiError';
    this.status = status;
    this.data = data;
  }
}

// Các hàm tiện ích quản lý JWT token trong localStorage
export const getToken = () => localStorage.getItem(TOKEN_KEY);

export const setToken = (token) => {
  if (token) {
    localStorage.setItem(TOKEN_KEY, token);
  } else {
    localStorage.removeItem(TOKEN_KEY);
  }
};

export const removeToken = () => localStorage.removeItem(TOKEN_KEY);

// Hàm cốt lõi xử lý mọi request HTTP
async function request(endpoint, options = {}) {
  // Tạo URL đầy đủ (chấp nhận cả path tương đối lẫn URL tuyệt đối)
  const url = endpoint.startsWith('http') ? endpoint : `${BASE_URL}${endpoint}`;
  const headers = new Headers(options.headers || {});

  // Tự động định dạng JSON cho request body nếu không phải là FormData (phục vụ upload file/hình ảnh)
  if (options.body && !(options.body instanceof FormData) && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
    if (typeof options.body === 'object') {
      options.body = JSON.stringify(options.body);
    }
  }

  // Tự động chèn token Authorization Bearer vào header nếu người dùng đã đăng nhập
  const token = getToken();
  if (token && !headers.has('Authorization')) {
    headers.set('Authorization', `Bearer ${token}`);
  }

  options.headers = headers;

  try {
    const response = await fetch(url, options);

    // Đọc dữ liệu trả về (ưu tiên parse JSON, nếu không phải JSON thì đọc dạng text)
    let data = null;
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      data = await response.json();
    } else {
      data = await response.text();
    }

    // Xử lý khi HTTP status không thành công (4xx, 5xx)
    if (!response.ok) {
      // Khi bị lỗi 401 Unauthorized: xóa token khỏi máy và phát sự kiện toàn cục để ứng dụng chuyển hướng về trang đăng nhập
      if (response.status === 401) {
        removeToken();
        window.dispatchEvent(new CustomEvent('api:unauthorized'));
      }
      const errorMessage = (data && data.message) || `Yêu cầu thất bại với status ${response.status}`;
      throw new ApiError(errorMessage, response.status, data);
    }

    return data;
  } catch (error) {
    if (error instanceof ApiError) throw error;
    // Bắt lỗi mất kết nối mạng hoặc lỗi runtime khác
    throw new ApiError(error.message || 'Lỗi kết nối mạng', 0, null);
  }
}

// Các phương thức HTTP viết tắt để sử dụng nhanh chóng và thuận tiện hơn
export const api = {
  get: (endpoint, options = {}) => request(endpoint, { ...options, method: 'GET' }),
  post: (endpoint, body, options = {}) => request(endpoint, { ...options, method: 'POST', body }),
  put: (endpoint, body, options = {}) => request(endpoint, { ...options, method: 'PUT', body }),
  patch: (endpoint, body, options = {}) => request(endpoint, { ...options, method: 'PATCH', body }),
  delete: (endpoint, options = {}) => request(endpoint, { ...options, method: 'DELETE' })
};

export default api;
