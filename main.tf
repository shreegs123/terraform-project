resource "aws_vpc" "terra-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "terra-vpc"
  }
}

resource "aws_subnet" "terra-subnet-1" {
  vpc_id = aws_vpc.terra-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "terra-subnet-2" {
  vpc_id = aws_vpc.terra-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "terra-subnet-3" {
  vpc_id = aws_vpc.terra-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
}

resource "aws_internet_gateway" "terra-ig" {
  vpc_id = aws_vpc.terra-vpc.id
  tags = {
    Name = "terra-interne-gateway"
  }
}

resource "aws_route_table" "terra-rt-public" {
  vpc_id = aws_vpc.terra-vpc.id
  tags = {
    Name = "terra-rt-public"
  }
}

resource "aws_route" "terra-public-ig" {
  route_table_id = "${aws_route_table.terra-rt-public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.terra-ig.id}"
  
}

resource "aws_route_table_association" "terra-public-1-a" {
  subnet_id = aws_subnet.terra-subnet-1.id
  route_table_id = aws_route_table.terra-rt-public.id
}

resource "aws_route_table_association" "terra-public-1-b" {
  subnet_id = aws_subnet.terra-subnet-2.id
  route_table_id = aws_route_table.terra-rt-public.id
}

resource "aws_eip" "terra-nat-eip" {
  vpc        = true
  depends_on = [ aws_internet_gateway.terra-ig ]
  }

resource "aws_nat_gateway" "terra-nat-gw" {
  allocation_id = "${aws_eip.terra-nat-eip.id}"
  subnet_id = aws_subnet.terra-subnet-1.id
  depends_on = [ aws_internet_gateway.terra-ig ]
}

resource "aws_route_table" "terra-rt-private" {
  vpc_id = aws_vpc.terra-vpc.id
  tags = {
    Name = "terra-rt-private"
  }
}

resource "aws_route" "terra-private-nat" {
  route_table_id = "${aws_route_table.terra-rt-private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.terra-nat-gw.id}"

}

resource "aws_route_table_association" "terra-private-1-c" {
  subnet_id = aws_subnet.terra-subnet-3.id
  route_table_id = aws_route_table.terra-rt-private.id
}

resource "aws_instance" "terra-instance-1" {
  ami= var.aws_instance
  instance_type = var.instance_type
  subnet_id = aws_subnet.terra-subnet-1.id
}

resource "aws_instance" "terra-instance-2" {
  ami= var.aws_instance
  instance_type = var.instance_type
  subnet_id = aws_subnet.terra-subnet-2.id
}

resource "aws_instance" "terra-instance-3" {
  ami = var.aws_instance
  instance_type = var.instance_type
  subnet_id = aws_subnet.terra-subnet-3.id
}