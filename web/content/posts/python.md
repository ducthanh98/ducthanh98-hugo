---
title: "Python Core: Context Managers, Generators & GIL"
date: 2024-01-15T10:00:00+07:00
draft: false
categories: ["Programming Languages"]
tags: ["Python", "Generators", "Concurrency", "GIL"]
---

# Python
## [Context Manager](#context)
## [Yield keyword](#yield)



# Context
- Context Manager giúp quản lý tài nguyên tự động, đảm bảo tài nguyên (file, database connection, network socket,...) được mở và đóng đúng cách.
- Đóng tài nguyên tự động, tránh lỗi quên close()
- Xử lý lỗi tự động, giảm code try-except-finally

```
class FileManager:
    def __init__(self, filename):
        self.filename = filename

    def __enter__(self):
        self.file = open(self.filename, "r")  # Mở file
        return self.file  # Trả về file để sử dụng trong `with`

    def __exit__(self, exc_type, exc_value, traceback):
        self.file.close()  # Đóng file khi thoát `with`
        if exc_type:
            print("Error:", exc_value)  # Xử lý lỗi (nếu có)
        return True  # Ngăn lỗi không dừng chương trình

with FileManager("test.txt") as f:
    print(f.read())  # File tự động đóng sau khi `with` kết thúc


import time
from contextlib import contextmanager

@contextmanager
def timer():
    start = time.time()
    yield  # Chạy code trong `with`
    end = time.time()
    print(f"Execution Time: {end - start:.2f}s")

with timer():
    time.sleep(2)  # Giả lập tác vụ mất 2s

```


# Yield
- yield là một từ khóa đặc biệt trong Python, được dùng trong generator function để tạo ra một iterator.
- Khác với return, yield không kết thúc hàm mà tạm dừng (pause) và giữ lại trạng thái, cho phép tiếp tục từ chỗ dừng khi next() được gọi.
- Dùng next() hoặc for để lấy từng giá trị từ generator.

# Multithreading
-  Python có hỗ trợ đa luồng thông qua module threading.
-  Nhưng bị giới hạn bởi GIL (Global Interpreter Lock) → chỉ 1 thread chạy Python code tại một thời điểm.
- GIL là một cơ chế trong Python giúp đảm bảo chỉ một thread chạy Python bytecode tại một thời điểm. Điều này tránh race condition nhưng lại hạn chế multi-threading cho CPU-bound tasks.
- nếu muốn Dùng nhiều process → mỗi process có GIL riêng → chạy song song thực sự.

