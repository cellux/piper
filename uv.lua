local ffi = require("ffi")
local jit = require("jit")

ffi.cdef [[
typedef enum {
  UV_UNKNOWN = -1,

  UV_OK = 0,
  UV_EOF = 1,
  UV_EADDRINFO = 2,
  UV_EACCES = 3,
  UV_EAGAIN = 4,
  UV_EADDRINUSE = 5,
  UV_EADDRNOTAVAIL = 6,
  UV_EAFNOSUPPORT = 7,
  UV_EALREADY = 8,
  UV_EBADF = 9,
  UV_EBUSY = 10,
  UV_ECONNABORTED = 11,
  UV_ECONNREFUSED = 12,
  UV_ECONNRESET = 13,
  UV_EDESTADDRREQ = 14,
  UV_EFAULT = 15,
  UV_EHOSTUNREACH = 16,
  UV_EINTR = 17,
  UV_EINVAL = 18,
  UV_EISCONN = 19,
  UV_EMFILE = 20,
  UV_EMSGSIZE = 21,
  UV_ENETDOWN = 22,
  UV_ENETUNREACH = 23,
  UV_ENFILE = 24,
  UV_ENOBUFS = 25,
  UV_ENOMEM = 26,
  UV_ENOTDIR = 27,
  UV_EISDIR = 28,
  UV_ENONET = 29,
  UV_ENOTCONN = 31,
  UV_ENOTSOCK = 32,
  UV_ENOTSUP = 33,
  UV_ENOENT = 34,
  UV_ENOSYS = 35,
  UV_EPIPE = 36,
  UV_EPROTO = 37,
  UV_EPROTONOSUPPORT = 38,
  UV_EPROTOTYPE = 39,
  UV_ETIMEDOUT = 40,
  UV_ECHARSET = 41,
  UV_EAIFAMNOSUPPORT = 42,
  UV_EAISERVICE = 44,
  UV_EAISOCKTYPE = 45,
  UV_ESHUTDOWN = 46,
  UV_EEXIST = 47,
  UV_ESRCH = 48,
  UV_ENAMETOOLONG = 49,
  UV_EPERM = 50,
  UV_ELOOP = 51,
  UV_EXDEV = 52,
  UV_ENOTEMPTY = 53,
  UV_ENOSPC = 54,
  UV_EIO = 55,
  UV_EROFS = 56,
  UV_ENODEV = 57,
  UV_ESPIPE = 58,
  UV_ECANCELED = 59,

  UV_MAX_ERRORS
} uv_err_code;

typedef enum {
  UV_UNKNOWN_HANDLE = 0,

  UV_ASYNC,
  UV_CHECK,
  UV_FS_EVENT,
  UV_FS_POLL,
  UV_HANDLE,
  UV_IDLE,
  UV_NAMED_PIPE,
  UV_POLL,
  UV_PREPARE,
  UV_PROCESS,
  UV_STREAM,
  UV_TCP,
  UV_TIMER,
  UV_TTY,
  UV_UDP,
  UV_SIGNAL,
  UV_FILE,

  UV_HANDLE_TYPE_MAX
} uv_handle_type;

typedef enum {
  UV_UNKNOWN_REQ = 0,

  UV_REQ,
  UV_CONNECT,
  UV_WRITE,
  UV_SHUTDOWN,
  UV_UDP_SEND,
  UV_FS,
  UV_WORK,
  UV_GETADDRINFO,
 
  UV_REQ_TYPE_MAX
} uv_req_type;

typedef struct uv_loop_s uv_loop_t;
typedef struct uv_err_s uv_err_t;
typedef struct uv_handle_s uv_handle_t;
typedef struct uv_stream_s uv_stream_t;
typedef struct uv_tcp_s uv_tcp_t;
typedef struct uv_udp_s uv_udp_t;
typedef struct uv_pipe_s uv_pipe_t;
typedef struct uv_tty_s uv_tty_t;
typedef struct uv_poll_s uv_poll_t;
typedef struct uv_timer_s uv_timer_t;
typedef struct uv_prepare_s uv_prepare_t;
typedef struct uv_check_s uv_check_t;
typedef struct uv_idle_s uv_idle_t;
typedef struct uv_async_s uv_async_t;
typedef struct uv_process_s uv_process_t;
typedef struct uv_fs_event_s uv_fs_event_t;
typedef struct uv_fs_poll_s uv_fs_poll_t;
typedef struct uv_signal_s uv_signal_t;

typedef struct uv_req_s uv_req_t;
typedef struct uv_getaddrinfo_s uv_getaddrinfo_t;
typedef struct uv_shutdown_s uv_shutdown_t;
typedef struct uv_write_s uv_write_t;
typedef struct uv_connect_s uv_connect_t;
typedef struct uv_udp_send_s uv_udp_send_t;
typedef struct uv_fs_s uv_fs_t;
typedef struct uv_work_s uv_work_t;

typedef struct uv_cpu_info_s uv_cpu_info_t;
typedef struct uv_interface_address_s uv_interface_address_t;

typedef struct ngx_queue_s ngx_queue_t;

struct ngx_queue_s {
  ngx_queue_t *prev;
  ngx_queue_t *next;
};

typedef void (*uv__io_cb)(struct uv_loop_s* loop,
                          struct uv__io_s* w,
                          unsigned int events);

struct uv__io_s {
  uv__io_cb cb;
  ngx_queue_t pending_queue;
  ngx_queue_t watcher_queue;
  unsigned int pevents;
  unsigned int events;
  int fd;
};

typedef struct uv__io_s uv__io_t;

typedef struct {
  char* base;
  size_t len;
} uv_buf_t;

typedef int uv_file;
typedef int uv_os_sock_t;
typedef struct stat uv_statbuf_t;

typedef int __ssize_t;
typedef __ssize_t ssize_t;

typedef uv_buf_t (*uv_alloc_cb)(uv_handle_t* handle, size_t suggested_size);
typedef void (*uv_read_cb)(uv_stream_t* stream, ssize_t nread, uv_buf_t buf);
typedef void (*uv_read2_cb)(uv_pipe_t* pipe, ssize_t nread, uv_buf_t buf, uv_handle_type pending);
typedef void (*uv_write_cb)(uv_write_t* req, int status);
typedef void (*uv_connect_cb)(uv_connect_t* req, int status);
typedef void (*uv_shutdown_cb)(uv_shutdown_t* req, int status);
typedef void (*uv_connection_cb)(uv_stream_t* server, int status);
typedef void (*uv_close_cb)(uv_handle_t* handle);
typedef void (*uv_poll_cb)(uv_poll_t* handle, int status, int events);
typedef void (*uv_timer_cb)(uv_timer_t* handle, int status);
typedef void (*uv_async_cb)(uv_async_t* handle, int status);
typedef void (*uv_prepare_cb)(uv_prepare_t* handle, int status);
typedef void (*uv_check_cb)(uv_check_t* handle, int status);
typedef void (*uv_idle_cb)(uv_idle_t* handle, int status);
typedef void (*uv_exit_cb)(uv_process_t*, int exit_status, int term_signal);
typedef void (*uv_walk_cb)(uv_handle_t* handle, void* arg);
typedef void (*uv_fs_cb)(uv_fs_t* req);
typedef void (*uv_work_cb)(uv_work_t* req);
typedef void (*uv_after_work_cb)(uv_work_t* req, int status);
typedef void (*uv_getaddrinfo_cb)(uv_getaddrinfo_t* req, int status, struct addrinfo* res);
typedef void (*uv_fs_event_cb)(uv_fs_event_t* handle, const char* filename, int events, int status);
typedef void (*uv_fs_poll_cb)(uv_fs_poll_t* handle, int status, const uv_statbuf_t* prev, const uv_statbuf_t* curr);
typedef void (*uv_signal_cb)(uv_signal_t* handle, int signum);

typedef enum {
  UV_RUN_DEFAULT = 0,
  UV_RUN_ONCE,
  UV_RUN_NOWAIT
} uv_run_mode;

uv_loop_t* uv_loop_new(void);
void uv_loop_delete(uv_loop_t*);
uv_loop_t* uv_default_loop(void);
int uv_run(uv_loop_t*, uv_run_mode mode);

struct uv_handle_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
};

void uv_ref(uv_handle_t*);
void uv_unref(uv_handle_t*);

void uv_update_time(uv_loop_t*);
int64_t uv_now(uv_loop_t*);
int uv_backend_fd(const uv_loop_t*);
int uv_backend_timeout(const uv_loop_t*);

typedef enum {
  UV_LEAVE_GROUP = 0,
  UV_JOIN_GROUP
} uv_membership;

struct uv_err_s {
  uv_err_code code;
  int sys_errno_;
};

uv_err_t uv_last_error(uv_loop_t*);
const char* uv_strerror(uv_err_t err);
const char* uv_err_name(uv_err_t err);

struct uv_stream_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  size_t write_queue_size;
  uv_alloc_cb alloc_cb;
  uv_read_cb read_cb;
  uv_read2_cb read2_cb;
  uv_connect_t *connect_req;
  uv_shutdown_t *shutdown_req;
  uv__io_t io_watcher;
  ngx_queue_t write_queue;
  ngx_queue_t write_completed_queue;
  uv_connection_cb connection_cb;
  int delayed_error;
  int accepted_fd;
};

struct uv_write_s {
  void* data;
  uv_req_type type;
  ngx_queue_t active_queue;
  uv_write_cb cb;
  uv_stream_t* send_handle;
  uv_stream_t* handle;
  ngx_queue_t queue;
  int write_index;
  uv_buf_t* bufs;
  int bufcnt;
  int error;
  uv_buf_t bufsml[4];
};

struct uv_shutdown_s {
  void* data;
  uv_req_type type;
  ngx_queue_t active_queue;
  uv_stream_t* handle;
  uv_shutdown_cb cb;
};

int uv_shutdown(uv_shutdown_t* req, uv_stream_t* handle, uv_shutdown_cb cb);

size_t uv_handle_size(uv_handle_type type);
size_t uv_req_size(uv_req_type type);

int uv_is_active(const uv_handle_t* handle);
void uv_walk(uv_loop_t* loop, uv_walk_cb walk_cb, void* arg);

void uv_close(uv_handle_t* handle, uv_close_cb close_cb);

uv_buf_t uv_buf_init(char* base, unsigned int len);

size_t uv_strlcpy(char* dst, const char* src, size_t size);
size_t uv_strlcat(char* dst, const char* src, size_t size);

int uv_listen(uv_stream_t* stream, int backlog, uv_connection_cb cb);
int uv_accept(uv_stream_t* server, uv_stream_t* client);
int uv_read_start(uv_stream_t*, uv_alloc_cb alloc_cb, uv_read_cb read_cb);
int uv_read_stop(uv_stream_t*);
int uv_read2_start(uv_stream_t*, uv_alloc_cb alloc_cb, uv_read2_cb read_cb);
int uv_write(uv_write_t* req, uv_stream_t* handle, uv_buf_t bufs[], int bufcnt, uv_write_cb cb);
int uv_write2(uv_write_t* req, uv_stream_t* handle, uv_buf_t bufs[], int bufcnt, uv_stream_t* send_handle, uv_write_cb cb);
int uv_is_readable(const uv_stream_t* handle);
int uv_is_writable(const uv_stream_t* handle);
int uv_is_closing(const uv_handle_t* handle);

typedef unsigned short int sa_family_t;
typedef uint16_t in_port_t;
typedef uint32_t in_addr_t;

struct in_addr {
  in_addr_t s_addr;
};

struct in6_addr {
  union {
    uint8_t __u6_addr8[16];
    uint16_t __u6_addr16[8];
    uint32_t __u6_addr32[4];
  } __in6_u;
};

struct sockaddr {
  sa_family_t sa_family;
  char sa_data[14];
};

struct sockaddr_in
{
   sa_family_t sin_family;
   in_port_t sin_port;
   struct in_addr sin_addr;
   unsigned char sin_zero[sizeof (struct sockaddr) -
                          (sizeof (unsigned short int)) -
                          sizeof (in_port_t) -
                          sizeof (struct in_addr)];
};

struct sockaddr_in6 {
  sa_family_t sin6_family;
  in_port_t sin6_port;
  uint32_t sin6_flowinfo;
  struct in6_addr sin6_addr;
  uint32_t sin6_scope_id;
};

struct uv_connect_s {
  void* data;
  uv_req_type type;
  ngx_queue_t active_queue;
  uv_connect_cb cb;
  uv_stream_t* handle;
  ngx_queue_t queue;
};

struct uv_tcp_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  size_t write_queue_size;
  uv_alloc_cb alloc_cb;
  uv_read_cb read_cb;
  uv_read2_cb read2_cb;
  uv_connect_t *connect_req;
  uv_shutdown_t *shutdown_req;
  uv__io_t io_watcher;
  ngx_queue_t write_queue;
  ngx_queue_t write_completed_queue;
  uv_connection_cb connection_cb;
  int delayed_error;
  int accepted_fd;
};

int uv_tcp_init(uv_loop_t*, uv_tcp_t* handle);
int uv_tcp_open(uv_tcp_t* handle, uv_os_sock_t sock);
int uv_tcp_nodelay(uv_tcp_t* handle, int enable);
int uv_tcp_keepalive(uv_tcp_t* handle, int enable, unsigned int delay);
int uv_tcp_simultaneous_accepts(uv_tcp_t* handle, int enable);
int uv_tcp_bind(uv_tcp_t* handle, struct sockaddr_in);
int uv_tcp_bind6(uv_tcp_t* handle, struct sockaddr_in6);
int uv_tcp_getsockname(uv_tcp_t* handle, struct sockaddr* name, int* namelen);
int uv_tcp_getpeername(uv_tcp_t* handle, struct sockaddr* name, int* namelen);
int uv_tcp_connect(uv_connect_t* req, uv_tcp_t* handle, struct sockaddr_in address, uv_connect_cb cb);
int uv_tcp_connect6(uv_connect_t* req, uv_tcp_t* handle, struct sockaddr_in6 address, uv_connect_cb cb);

enum uv_udp_flags {
  UV_UDP_IPV6ONLY = 1,
  UV_UDP_PARTIAL = 2
};

typedef void (*uv_udp_send_cb)(uv_udp_send_t* req, int status);
typedef void (*uv_udp_recv_cb)(uv_udp_t* handle, ssize_t nread, uv_buf_t buf, struct sockaddr* addr, unsigned flags);

struct uv_udp_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  uv_alloc_cb alloc_cb;
  uv_udp_recv_cb recv_cb;
  uv__io_t io_watcher;
  ngx_queue_t write_queue;
  ngx_queue_t write_completed_queue;
};

struct uv_udp_send_s {
  void* data;
  uv_req_type type;
  ngx_queue_t active_queue;
  uv_udp_t* handle;
  uv_udp_send_cb cb;
  ngx_queue_t queue;
  struct sockaddr_in6 addr;
  int bufcnt;
  uv_buf_t* bufs;
  size_t status;
  uv_udp_send_cb send_cb;
  uv_buf_t bufsml[4];
};

int uv_udp_init(uv_loop_t*, uv_udp_t* handle);
int uv_udp_open(uv_udp_t* handle, uv_os_sock_t sock);
int uv_udp_bind(uv_udp_t* handle, struct sockaddr_in addr, unsigned flags);
int uv_udp_bind6(uv_udp_t* handle, struct sockaddr_in6 addr, unsigned flags);
int uv_udp_getsockname(uv_udp_t* handle, struct sockaddr* name, int* namelen);
int uv_udp_set_membership(uv_udp_t* handle, const char* multicast_addr, const char* interface_addr, uv_membership membership);
int uv_udp_set_multicast_loop(uv_udp_t* handle, int on);
int uv_udp_set_multicast_ttl(uv_udp_t* handle, int ttl);
int uv_udp_set_broadcast(uv_udp_t* handle, int on);
int uv_udp_set_ttl(uv_udp_t* handle, int ttl);
int uv_udp_send(uv_udp_send_t* req, uv_udp_t* handle, uv_buf_t bufs[], int bufcnt, struct sockaddr_in addr, uv_udp_send_cb send_cb);
int uv_udp_send6(uv_udp_send_t* req, uv_udp_t* handle, uv_buf_t bufs[], int bufcnt, struct sockaddr_in6 addr, uv_udp_send_cb send_cb);
int uv_udp_recv_start(uv_udp_t* handle, uv_alloc_cb alloc_cb, uv_udp_recv_cb recv_cb);
int uv_udp_recv_stop(uv_udp_t* handle);

typedef unsigned char cc_t;
typedef unsigned int speed_t;
typedef unsigned int tcflag_t;

struct termios {
  tcflag_t c_iflag;
  tcflag_t c_oflag;
  tcflag_t c_cflag;
  tcflag_t c_lflag;
  cc_t c_line;
  cc_t c_cc[32];
  speed_t c_ispeed;
  speed_t c_ospeed;
};

struct uv_tty_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  size_t write_queue_size;
  uv_alloc_cb alloc_cb;
  uv_read_cb read_cb;
  uv_read2_cb read2_cb;
  uv_connect_t *connect_req;
  uv_shutdown_t *shutdown_req;
  uv__io_t io_watcher;
  ngx_queue_t write_queue;
  ngx_queue_t write_completed_queue;
  uv_connection_cb connection_cb;
  int delayed_error;
  int accepted_fd;
  struct termios orig_termios;
  int mode;
};

int uv_tty_init(uv_loop_t*, uv_tty_t*, uv_file fd, int readable);
int uv_tty_set_mode(uv_tty_t*, int mode);
void uv_tty_reset_mode(void);
int uv_tty_get_winsize(uv_tty_t*, int* width, int* height);
uv_handle_type uv_guess_handle(uv_file file);

struct uv_pipe_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  size_t write_queue_size;
  uv_alloc_cb alloc_cb;
  uv_read_cb read_cb;
  uv_read2_cb read2_cb;
  uv_connect_t *connect_req;
  uv_shutdown_t *shutdown_req;
  uv__io_t io_watcher;
  ngx_queue_t write_queue;
  ngx_queue_t write_completed_queue;
  uv_connection_cb connection_cb;
  int delayed_error;
  int accepted_fd;
  int ipc;
  const char* pipe_fname;
};

int uv_pipe_init(uv_loop_t*, uv_pipe_t* handle, int ipc);
int uv_pipe_open(uv_pipe_t*, uv_file file);
int uv_pipe_bind(uv_pipe_t* handle, const char* name);
void uv_pipe_connect(uv_connect_t* req, uv_pipe_t* handle, const char* name, uv_connect_cb cb);
void uv_pipe_pending_instances(uv_pipe_t* handle, int count);

struct uv_poll_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  uv_poll_cb poll_cb;
  uv__io_t io_watcher;
};

enum uv_poll_event {
  UV_READABLE = 1,
  UV_WRITABLE = 2
};

int uv_poll_init(uv_loop_t* loop, uv_poll_t* handle, int fd);
int uv_poll_init_socket(uv_loop_t* loop, uv_poll_t* handle, uv_os_sock_t socket);
int uv_poll_start(uv_poll_t* handle, int events, uv_poll_cb cb);
int uv_poll_stop(uv_poll_t* handle);

struct uv_prepare_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  uv_prepare_cb prepare_cb;
  ngx_queue_t queue;
};

int uv_prepare_init(uv_loop_t*, uv_prepare_t* prepare);
int uv_prepare_start(uv_prepare_t* prepare, uv_prepare_cb cb);
int uv_prepare_stop(uv_prepare_t* prepare);

struct uv_check_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  uv_check_cb check_cb;
  ngx_queue_t queue;
};

int uv_check_init(uv_loop_t*, uv_check_t* check);
int uv_check_start(uv_check_t* check, uv_check_cb cb);
int uv_check_stop(uv_check_t* check);

struct uv_idle_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  uv_idle_cb idle_cb;
  ngx_queue_t queue;
};

int uv_idle_init(uv_loop_t*, uv_idle_t* idle);
int uv_idle_start(uv_idle_t* idle, uv_idle_cb cb);
int uv_idle_stop(uv_idle_t* idle);

typedef int __sig_atomic_t;
typedef __sig_atomic_t sig_atomic_t;

struct uv_async_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  volatile sig_atomic_t pending;
  uv_async_cb async_cb;
  ngx_queue_t queue;
};

int uv_async_init(uv_loop_t*, uv_async_t* async, uv_async_cb async_cb);
int uv_async_send(uv_async_t* async);

struct uv_timer_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  struct {
    struct uv_timer_s* rbe_left;
    struct uv_timer_s* rbe_right;
    struct uv_timer_s* rbe_parent;
    int rbe_color;
  } tree_entry;
  uv_timer_cb timer_cb;
  uint64_t timeout;
  uint64_t repeat;
};

int uv_timer_init(uv_loop_t*, uv_timer_t* timer);
int uv_timer_start(uv_timer_t* timer, uv_timer_cb cb, int64_t timeout, int64_t repeat);
int uv_timer_stop(uv_timer_t* timer);
int uv_timer_again(uv_timer_t* timer);
void uv_timer_set_repeat(uv_timer_t* timer, int64_t repeat);
int64_t uv_timer_get_repeat(uv_timer_t* timer);

typedef unsigned int __socklen_t;
typedef __socklen_t socklen_t;

struct addrinfo {
  int ai_flags;
  int ai_family;
  int ai_socktype;
  int ai_protocol;
  socklen_t ai_addrlen;
  struct sockaddr *ai_addr;
  char *ai_canonname;
  struct addrinfo *ai_next;
};

struct uv__work {
  void (*work)(struct uv__work *w);
  void (*done)(struct uv__work *w, int status);
  struct uv_loop_s* loop;
  ngx_queue_t wq;
};

struct uv_getaddrinfo_s {
  void* data;
  uv_req_type type;
  ngx_queue_t active_queue;
  uv_loop_t* loop;
  struct uv__work work_req;
  uv_getaddrinfo_cb cb;
  struct addrinfo* hints;
  char* hostname;
  char* service;
  struct addrinfo* res;
  int retcode;
};

int uv_getaddrinfo(uv_loop_t* loop, uv_getaddrinfo_t* req, uv_getaddrinfo_cb getaddrinfo_cb, const char* node, const char* service, const struct addrinfo* hints);
void uv_freeaddrinfo(struct addrinfo* ai);

typedef enum {
  UV_IGNORE = 0x00,
  UV_CREATE_PIPE = 0x01,
  UV_INHERIT_FD = 0x02,
  UV_INHERIT_STREAM = 0x04,
  UV_READABLE_PIPE = 0x10,
  UV_WRITABLE_PIPE = 0x20
} uv_stdio_flags;

typedef struct uv_stdio_container_s {
  uv_stdio_flags flags;
  union {
    uv_stream_t* stream;
    int fd;
  } data;
} uv_stdio_container_t;

typedef unsigned int __uid_t;
typedef unsigned int __gid_t;

typedef __uid_t uid_t;
typedef __gid_t gid_t;

typedef gid_t uv_gid_t;
typedef uid_t uv_uid_t;

typedef struct uv_process_options_s {
  uv_exit_cb exit_cb;
  const char* file;
  char** args;
  char** env;
  char* cwd;
  unsigned int flags;
  int stdio_count;
  uv_stdio_container_t* stdio;
  uv_uid_t uid;
  uv_gid_t gid;
} uv_process_options_t;

enum uv_process_flags {
  UV_PROCESS_SETUID = (1 << 0),
  UV_PROCESS_SETGID = (1 << 1),
  UV_PROCESS_WINDOWS_VERBATIM_ARGUMENTS = (1 << 2),
  UV_PROCESS_DETACHED = (1 << 3),
  UV_PROCESS_WINDOWS_HIDE = (1 << 4)
};

struct uv_process_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  uv_exit_cb exit_cb;
  int pid;
  ngx_queue_t queue;
  int errorno;
};

int uv_spawn(uv_loop_t*, uv_process_t*, uv_process_options_t options);
int uv_process_kill(uv_process_t*, int signum);
uv_err_t uv_kill(int pid, int signum);

struct uv_work_s {
  void* data;
  uv_req_type type;
  ngx_queue_t active_queue;
  uv_loop_t* loop;
  uv_work_cb work_cb;
  uv_after_work_cb after_work_cb;
  struct uv__work work_req;
};

int uv_queue_work(uv_loop_t* loop, uv_work_t* req, uv_work_cb work_cb, uv_after_work_cb after_work_cb);
int uv_cancel(uv_req_t* req);

struct uv_cpu_info_s {
  char* model;
  int speed;
  struct uv_cpu_times_s {
    uint64_t user;
    uint64_t nice;
    uint64_t sys;
    uint64_t idle;
    uint64_t irq;
  } cpu_times;
};

struct uv_interface_address_s {
  char* name;
  int is_internal;
  union {
    struct sockaddr_in address4;
    struct sockaddr_in6 address6;
  } address;
};

char** uv_setup_args(int argc, char** argv);
uv_err_t uv_get_process_title(char* buffer, size_t size);
uv_err_t uv_set_process_title(const char* title);
uv_err_t uv_resident_set_memory(size_t* rss);
uv_err_t uv_uptime(double* uptime);

uv_err_t uv_cpu_info(uv_cpu_info_t** cpu_infos, int* count);
void uv_free_cpu_info(uv_cpu_info_t* cpu_infos, int count);

uv_err_t uv_interface_addresses(uv_interface_address_t** addresses, int* count);
void uv_free_interface_addresses(uv_interface_address_t* addresses, int count);

typedef enum {
  UV_FS_UNKNOWN = -1,
  UV_FS_CUSTOM,
  UV_FS_OPEN,
  UV_FS_CLOSE,
  UV_FS_READ,
  UV_FS_WRITE,
  UV_FS_SENDFILE,
  UV_FS_STAT,
  UV_FS_LSTAT,
  UV_FS_FSTAT,
  UV_FS_FTRUNCATE,
  UV_FS_UTIME,
  UV_FS_FUTIME,
  UV_FS_CHMOD,
  UV_FS_FCHMOD,
  UV_FS_FSYNC,
  UV_FS_FDATASYNC,
  UV_FS_UNLINK,
  UV_FS_RMDIR,
  UV_FS_MKDIR,
  UV_FS_RENAME,
  UV_FS_READDIR,
  UV_FS_LINK,
  UV_FS_SYMLINK,
  UV_FS_READLINK,
  UV_FS_CHOWN,
  UV_FS_FCHOWN
} uv_fs_type;

typedef unsigned int __mode_t;
typedef __mode_t mode_t;

typedef long int __off_t;
typedef __off_t off_t;

typedef unsigned long long int __u_quad_t;
typedef __u_quad_t __dev_t;
typedef unsigned long int __ino_t;
typedef unsigned int __nlink_t;
typedef long int __blksize_t;
typedef long int __blkcnt_t;

typedef long int __time_t;
typedef long int __syscall_slong_t;

struct timespec {
  __time_t tv_sec;
  __syscall_slong_t tv_nsec;
};

struct stat {
  __dev_t st_dev;
  unsigned short int __pad1;
  __ino_t st_ino;
  __mode_t st_mode;
  __nlink_t st_nlink;
  __uid_t st_uid;
  __gid_t st_gid;
  __dev_t st_rdev;
  unsigned short int __pad2;
  __off_t st_size;
  __blksize_t st_blksize;
  __blkcnt_t st_blocks;
  struct timespec st_atim;
  struct timespec st_mtim;
  struct timespec st_ctim;
  unsigned long int __unused4;
  unsigned long int __unused5;
};

typedef enum {
  O_ACCMODE   = 0003,
  O_RDONLY    = 00,
  O_WRONLY    = 01,
  O_RDWR      = 02,
  O_CREAT     = 0100, /* not fcntl */
  O_EXCL      = 0200, /* not fcntl */
  O_NOCTTY    = 0400, /* not fcntl */
  O_TRUNC     = 01000, /* not fcntl */
  O_APPEND    = 02000,
  O_NONBLOCK  = 04000,
  O_NDELAY    = O_NONBLOCK,
  O_SYNC      = 04010000,
  O_FSYNC     = O_SYNC,
  O_ASYNC     = 020000,
  O_DIRECTORY = 0200000, /* Must be a directory.  */
  O_NOFOLLOW  = 0400000, /* Do not follow links.  */
  O_CLOEXEC   = 02000000, /* Set close_on_exec.  */
  O_DIRECT    = 040000, /* Direct disk access.  */
  O_NOATIME   = 01000000, /* Do not set atime.  */
  O_PATH      = 010000000, /* Resolve pathname but do not open file */
} open_flags;

typedef enum {
  S_ISUID  = 04000,   /* Set user ID on execution.  */
  S_ISGID  = 02000,   /* Set group ID on execution.  */
  S_ISVTX  = 01000,   /* Save swapped text after use (sticky).  */
  S_IREAD  = 0400,    /* Read by owner.  */
  S_IWRITE = 0200,    /* Write by owner.  */
  S_IEXEC  = 0100,    /* Execute by owner.  */

  S_IRUSR  = S_IREAD,       /* Read by owner.  */
  S_IWUSR  = S_IWRITE,      /* Write by owner.  */
  S_IXUSR  = S_IEXEC,       /* Execute by owner.  */
  /* Read, write, and execute by owner.  */
  S_IRWXU  = (S_IREAD|S_IWRITE|S_IEXEC),

  S_IRGRP  = (S_IRUSR >> 3),  /* Read by group.  */
  S_IWGRP  = (S_IWUSR >> 3),  /* Write by group.  */
  S_IXGRP  = (S_IXUSR >> 3),  /* Execute by group.  */
  /* Read, write, and execute by group.  */
  S_IRWXG  = (S_IRWXU >> 3),
  
  S_IROTH  = (S_IRGRP >> 3),  /* Read by others.  */
  S_IWOTH  = (S_IWGRP >> 3),  /* Write by others.  */
  S_IXOTH  = (S_IXGRP >> 3),  /* Execute by others.  */
  /* Read, write, and execute by others.  */
  S_IRWXO  = (S_IRWXG >> 3),
} permission_bits;

struct uv_fs_s {
  void* data;
  uv_req_type type;
  ngx_queue_t active_queue;
  uv_fs_type fs_type;
  uv_loop_t* loop;
  uv_fs_cb cb;
  ssize_t result;
  void* ptr;
  const char* path;
  uv_err_code errorno;
  const char *new_path;
  uv_file file;
  int flags;
  mode_t mode;
  void* buf;
  size_t len;
  off_t off;
  uid_t uid;
  gid_t gid;
  double atime;
  double mtime;
  struct uv__work work_req;
  struct stat statbuf;
};

void uv_fs_req_cleanup(uv_fs_t* req);
int uv_fs_close(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb);
int uv_fs_open(uv_loop_t* loop, uv_fs_t* req, const char* path, int flags, int mode, uv_fs_cb cb);
int uv_fs_read(uv_loop_t* loop, uv_fs_t* req, uv_file file, void* buf, size_t length, int64_t offset, uv_fs_cb cb);
int uv_fs_unlink(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb);
int uv_fs_write(uv_loop_t* loop, uv_fs_t* req, uv_file file, void* buf, size_t length, int64_t offset, uv_fs_cb cb);
int uv_fs_mkdir(uv_loop_t* loop, uv_fs_t* req, const char* path, int mode, uv_fs_cb cb);
int uv_fs_rmdir(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb);
int uv_fs_readdir(uv_loop_t* loop, uv_fs_t* req, const char* path, int flags, uv_fs_cb cb);
int uv_fs_stat(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb);
int uv_fs_fstat(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb);
int uv_fs_rename(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, uv_fs_cb cb);
int uv_fs_fsync(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb);
int uv_fs_fdatasync(uv_loop_t* loop, uv_fs_t* req, uv_file file, uv_fs_cb cb);
int uv_fs_ftruncate(uv_loop_t* loop, uv_fs_t* req, uv_file file, int64_t offset, uv_fs_cb cb);
int uv_fs_sendfile(uv_loop_t* loop, uv_fs_t* req, uv_file out_fd, uv_file in_fd, int64_t in_offset, size_t length, uv_fs_cb cb);
int uv_fs_chmod(uv_loop_t* loop, uv_fs_t* req, const char* path, int mode, uv_fs_cb cb);
int uv_fs_utime(uv_loop_t* loop, uv_fs_t* req, const char* path, double atime, double mtime, uv_fs_cb cb);
int uv_fs_futime(uv_loop_t* loop, uv_fs_t* req, uv_file file, double atime, double mtime, uv_fs_cb cb);
int uv_fs_lstat(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb);
int uv_fs_link(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, uv_fs_cb cb);
int uv_fs_symlink(uv_loop_t* loop, uv_fs_t* req, const char* path, const char* new_path, int flags, uv_fs_cb cb);
int uv_fs_readlink(uv_loop_t* loop, uv_fs_t* req, const char* path, uv_fs_cb cb);
int uv_fs_fchmod(uv_loop_t* loop, uv_fs_t* req, uv_file file, int mode, uv_fs_cb cb);
int uv_fs_chown(uv_loop_t* loop, uv_fs_t* req, const char* path, int uid, int gid, uv_fs_cb cb);
int uv_fs_fchown(uv_loop_t* loop, uv_fs_t* req, uv_file file, int uid, int gid, uv_fs_cb cb);

enum uv_fs_event {
  UV_RENAME = 1,
  UV_CHANGE = 2
};

struct uv_fs_event_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  char* filename;
  uv_fs_event_cb cb;
  ngx_queue_t watchers;
  int wd;
};

struct uv_fs_poll_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  void* poll_ctx;
};

int uv_fs_poll_init(uv_loop_t* loop, uv_fs_poll_t* handle);
int uv_fs_poll_start(uv_fs_poll_t* handle, uv_fs_poll_cb poll_cb, const char* path, unsigned int interval);
int uv_fs_poll_stop(uv_fs_poll_t* handle);

struct uv_signal_s {
  uv_close_cb close_cb;
  void* data;
  uv_loop_t* loop;
  uv_handle_type type;
  ngx_queue_t handle_queue;
  int flags;
  uv_handle_t* next_closing;
  uv_signal_cb signal_cb;
  int signum;
  struct {
    struct uv_signal_s* rbe_left;
    struct uv_signal_s* rbe_right;
    struct uv_signal_s* rbe_parent;
    int rbe_color;
  } tree_entry;
  unsigned int caught_signals;
  unsigned int dispatched_signals;
};

int uv_signal_init(uv_loop_t* loop, uv_signal_t* handle);
int uv_signal_start(uv_signal_t* handle, uv_signal_cb signal_cb, int signum);
int uv_signal_stop(uv_signal_t* handle);

static const int SIGHUP    = 1;      /* Hangup (POSIX).  */
static const int SIGINT    = 2;      /* Interrupt (ANSI).  */
static const int SIGQUIT   = 3;      /* Quit (POSIX).  */
static const int SIGILL    = 4;      /* Illegal instruction (ANSI).  */
static const int SIGTRAP   = 5;      /* Trace trap (POSIX).  */
static const int SIGABRT   = 6;      /* Abort (ANSI).  */
static const int SIGIOT    = 6;      /* IOT trap (4.2 BSD).  */
static const int SIGBUS    = 7;      /* BUS error (4.2 BSD).  */
static const int SIGFPE    = 8;      /* Floating-point exception (ANSI).  */
static const int SIGKILL   = 9;      /* Kill, unblockable (POSIX).  */
static const int SIGUSR1   = 10;     /* User-defined signal 1 (POSIX).  */
static const int SIGSEGV   = 11;     /* Segmentation violation (ANSI).  */
static const int SIGUSR2   = 12;     /* User-defined signal 2 (POSIX).  */
static const int SIGPIPE   = 13;     /* Broken pipe (POSIX).  */
static const int SIGALRM   = 14;     /* Alarm clock (POSIX).  */
static const int SIGTERM   = 15;     /* Termination (ANSI).  */
static const int SIGSTKFLT = 16;     /* Stack fault.  */
static const int SIGCHLD   = 17;     /* Child status has changed (POSIX).  */
static const int SIGCLD    = SIGCHLD;/* Same as SIGCHLD (System V).  */
static const int SIGCONT   = 18;     /* Continue (POSIX).  */
static const int SIGSTOP   = 19;     /* Stop, unblockable (POSIX).  */
static const int SIGTSTP   = 20;     /* Keyboard stop (POSIX).  */
static const int SIGTTIN   = 21;     /* Background read from tty (POSIX).  */
static const int SIGTTOU   = 22;     /* Background write to tty (POSIX).  */
static const int SIGURG    = 23;     /* Urgent condition on socket (4.2 BSD).  */
static const int SIGXCPU   = 24;     /* CPU limit exceeded (4.2 BSD).  */
static const int SIGXFSZ   = 25;     /* File size limit exceeded (4.2 BSD).  */
static const int SIGVTALRM = 26;     /* Virtual alarm clock (4.2 BSD).  */
static const int SIGPROF   = 27;     /* Profiling alarm clock (4.2 BSD).  */
static const int SIGWINCH  = 28;     /* Window size change (4.3 BSD, Sun).  */
static const int SIGIO     = 29;     /* I/O now possible (4.2 BSD).  */
static const int SIGPOLL   = SIGIO;  /* Pollable event occurred (System V).  */
static const int SIGPWR    = 30;     /* Power failure restart (System V).  */
static const int SIGSYS    = 31;     /* Bad system call.  */
static const int SIGUNUSED = 31;

void uv_loadavg(double avg[3]);

enum uv_fs_event_flags {
  UV_FS_EVENT_WATCH_ENTRY = 1,
  UV_FS_EVENT_STAT = 2,
  UV_FS_EVENT_RECURSIVE = 3
};

int uv_fs_event_init(uv_loop_t* loop, uv_fs_event_t* handle, const char* filename, uv_fs_event_cb cb, int flags);

struct sockaddr_in uv_ip4_addr(const char* ip, int port);
struct sockaddr_in6 uv_ip6_addr(const char* ip, int port);
int uv_ip4_name(struct sockaddr_in* src, char* dst, size_t size);
int uv_ip6_name(struct sockaddr_in6* src, char* dst, size_t size);
uv_err_t uv_inet_ntop(int af, const void* src, char* dst, size_t size);
uv_err_t uv_inet_pton(int af, const char* src, void* dst);
int uv_exepath(char* buffer, size_t* size);
uv_err_t uv_cwd(char* buffer, size_t size);
uv_err_t uv_chdir(const char* dir);
uint64_t uv_get_free_memory(void);
uint64_t uv_get_total_memory(void);
uint64_t uv_hrtime(void);
void uv_disable_stdio_inheritance(void);

typedef struct {
  void* handle;
  char* errmsg;
} uv_lib_t;

int uv_dlopen(const char* filename, uv_lib_t* lib);
void uv_dlclose(uv_lib_t* lib);
int uv_dlsym(uv_lib_t* lib, const char* name, void** ptr);
const char* uv_dlerror(uv_lib_t* lib);

/* TODO: thread-related stuff (mutex, rwlock, sem, cond, barrier, thread) */

]]

ffi.load('libpthread.so.0', true)
local uv = setmetatable({_NAME="uv"},
                        { __index = ffi.load("uv") })

local loop = uv.uv_default_loop()

local watcher_data = {}

local threads = {}
local waiting = {}
local waiting_count = 0

local watcher_functions = {
   idle = {
      init = function(w) uv.uv_idle_init(loop, w) end,
      start = function(w, h, d) uv.uv_idle_start(w, h) end,
      stop = function(w) uv.uv_idle_stop(w) end,
   },
   timer = {
      init = function(w) uv.uv_timer_init(loop, w) end,
      start = function(w, h, d) uv.uv_timer_start(w, h, d["timeout"] or 0, d["repeat"] or 0) end,
      stop = function(w) uv.uv_timer_stop(w) end,
   },
   signal = {
      init = function(w) uv.uv_signal_init(loop, w) end,
      start = function(w, h, d) uv.uv_signal_start(w, h, d["signum"]) end,
      stop = function(w) uv.uv_signal_stop(w) end,
   },
}

-- watcher -> watcher index (to get something useable as a table key)
local function w2i(w)
   return tonumber(ffi.cast("uint32_t", w))
end

local function wake_up_if_waiting(wi)
   if waiting[wi] then
      table.insert(threads, waiting[wi])
      waiting[wi] = nil
      waiting_count = waiting_count - 1
   end
end

function uv.watch(type, cb, data)
   data = data or {}
   local function handler(w)
      local wi = w2i(w)
      local res
      if cb then
         res = cb(data)
      else
         res = "stop"
      end
      if res == "stop" then
         watcher_functions[type].stop(w)
         local function close_cb(w)
           data._h:free()
           data._close_h:free()
           watcher_data[wi] = nil
         end
         data._close_h = ffi.cast("uv_close_cb", close_cb)
         uv.uv_close(ffi.cast("uv_handle_t*", w), data._close_h)
      end
      wake_up_if_waiting(wi)
   end
   local w = ffi.new("uv_"..type.."_t[1]")
   data._w = w
   watcher_functions[type].init(w)
   local h = ffi.cast("uv_"..type.."_cb", handler)
   data._h = h
   watcher_functions[type].start(w, h, data)
   local wi = w2i(w)
   watcher_data[wi] = data
   return w
end

local function last_error()
   return ffi.string(uv.uv_strerror(uv.uv_last_error(loop)))
end

local function fs_func(name, start_fn, ret_fn)
   local function default_ret_fn(w)
      return w[0].result
   end
   ret_fn = ret_fn or default_ret_fn
   local data = {}
   local rv = nil
   local function handler(w)
      rv = ret_fn(w)
      uv.uv_fs_req_cleanup(w)
      data._h:free()
      local wi = w2i(w)
      watcher_data[wi] = nil
      wake_up_if_waiting(wi)
   end
   local w = ffi.new("uv_fs_t[1]")
   data._w = w
   local h = ffi.cast("uv_fs_cb", handler)
   data._h = h
   local wi = w2i(w)
   watcher_data[wi] = data
   if start_fn(loop, w, h) ~= 0 then
      error(name.." failed: "..last_error())
   end
   uv.yield(w)
   return rv
end

function uv.fs_open(path, flags, mode)
   if type(mode) == "string" then
      mode = tonumber(mode, 8)
   end
   local function start_fn(loop, w, h)
      return uv.uv_fs_open(loop, w, path, flags, mode, h)
   end
   return fs_func("fs_open", start_fn)
end

function uv.fs_read(fd, buf, length, offset)
   -- returns the number of bytes read
   local function start_fn(loop, w, h)
      return uv.uv_fs_read(loop, w, fd, ffi.cast("void*", buf), length or #buf, offset or -1, h)
   end
   return fs_func("fs_read", start_fn)
end

function uv.fs_write(fd, buf, length, offset)
   local function start_fn(loop, w, h)
      return uv.uv_fs_write(loop, w, fd, ffi.cast("void*", buf), length or #buf, offset or -1, h)
   end
   return fs_func("fs_write", start_fn)
end

function uv.fs_ftruncate(fd, offset)
   local function start_fn(loop, w, h)
      return uv.uv_fs_ftruncate(loop, w, fd, offset, h)
   end
   return fs_func("fs_ftruncate", start_fn)
end

function uv.fs_close(fd)
   local function start_fn(loop, w, h)
      return uv.uv_fs_close(loop, w, fd, h)
   end
   return fs_func("fs_close", start_fn)
end

function uv.fs_unlink(path)
   local function start_fn(loop, w, h)
      return uv.uv_fs_unlink(loop, w, path, h)
   end
   return fs_func("fs_unlink", start_fn)
end

function uv.fs_mkdir(path, mode)
   if type(mode) == "string" then
      mode = tonumber(mode, 8)
   end
   local function start_fn(loop, w, h)
      return uv.uv_fs_mkdir(loop, w, path, mode, h)
   end
   return fs_func("fs_mkdir", start_fn)
end

function uv.fs_rmdir(path)
   local function start_fn(loop, w, h)
      return uv.uv_fs_rmdir(loop, w, path, h)
   end
   return fs_func("fs_rmdir", start_fn)
end

function uv.fs_readdir(path, flags)
   local function start_fn(loop, w, h)
      return uv.uv_fs_readdir(loop, w, path, flags or 0, h)
   end
   local function ret_fn(w)
      local p = ffi.cast("char*", w[0].ptr)
      local n = w[0].result
      local files = {}
      while (n > 0) do
         local s = ffi.string(p)
         table.insert(files, s)
         p = p + #s + 1
         n = n - 1
      end
      return files
   end
   return fs_func("fs_readdir", start_fn, ret_fn)
end

function uv.fs_rename(path, new_path)
   local function start_fn(loop, w, h)
      return uv.uv_fs_rename(loop, w, path, new_path, h)
   end
   return fs_func("fs_rename", start_fn)
end

function uv.sleep(seconds)
   local w = uv.watch("timer", nil, { timeout = seconds*1000 })
   uv.yield(w)
end

function uv.sched(f)
   local t = coroutine.create(f)
   table.insert(threads, t)
end

function uv.yield(arg)
   coroutine.yield(arg or "continue")
end

function uv.resume()
   local i = 1
   while i <= #threads do
      local t = threads[i]
      local success, rv = coroutine.resume(t)
      if success then
         if rv == "continue" then
            --
         else
            table.remove(threads, i)
            if type(rv) == "cdata" then
               -- must be a watcher
               local wi = w2i(rv)
               waiting[wi] = t
               waiting_count = waiting_count + 1
            end
         end
      else
         error("coroutine.resume() failed: "..tostring(rv))
      end
      i = i + 1
   end
   if #threads == 0 and waiting_count == 0 then
      return "stop"
   end
end

function uv.run(main)
   uv.watch("idle", uv.resume)
   if main then
      uv.sched(main)
   end
   uv.uv_run(loop, uv.UV_RUN_DEFAULT)
end

function uv.run_once()
   uv.uv_run(loop, uv.UV_RUN_ONCE)
end

function uv.run_nowait()
   uv.uv_run(loop, uv.UV_RUN_NOWAIT)
end

return uv
