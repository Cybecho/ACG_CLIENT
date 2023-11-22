import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

#34.207.178.168
server_address = ('ec2-34-207-178-168.compute-1.amazonaws.com', <PORT NUMBER>)  # 서버의 IP 주소와 포트 번호를 튜플로 지정

sock.connect(server_address)  # 서버와의 연결시도

sock.send("hello".encode())  # 서버에게 데이터를 전송
