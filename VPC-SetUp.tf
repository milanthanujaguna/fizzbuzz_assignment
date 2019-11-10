data "aws_availability_zones" "available" {}

resource "aws_vpc" "VPC" {
  cidr_block = "10.0.0.0/16"    
  enable_dns_hostnames  = true
  tags = {
    Name = "VPC-10.0.0.0"
  }
}

resource "aws_subnet" "VPC-az1-subnets" {
  count = 2
  availability_zone = "${data.aws_availability_zones.available.names[0]}"
  vpc_id     = "${aws_vpc.VPC.id}"
  cidr_block = "10.0.${count.index}.0/24"
  tags = {
    Name = "VPC-az1-subnets-${data.aws_availability_zones.available.names[0]}-${count.index}"
  }
}

resource "aws_subnet" "VPC-az2-subnets" {
    count = 2
  availability_zone = "${data.aws_availability_zones.available.names[1]}"
  vpc_id     = "${aws_vpc.VPC.id}"
  cidr_block = "10.0.${count.index+2}.0/24"
  tags = {
    Name = "VPC-az2-subnets-${data.aws_availability_zones.available.names[1]}-${count.index+2}"
  }
}


resource "aws_internet_gateway" "VPC-gw" {
  vpc_id = "${aws_vpc.VPC.id}"
}

resource "aws_eip" "VPC-eip"{}
resource "aws_eip" "VPC-eip-1"{}
resource "aws_nat_gateway" "VPC-az1-ng"{
   allocation_id = "${aws_eip.VPC-eip-1.id}"
   subnet_id     = "${aws_subnet.VPC-az1-subnets.*.id[1]}"
}

resource "aws_nat_gateway" "VPC-az2-ng"{
 allocation_id = "${aws_eip.VPC-eip.id}"
   subnet_id     = "${aws_subnet.VPC-az2-subnets.*.id[1]}"
}

resource "aws_route_table" "VPC-pub" {
  vpc_id = "${aws_vpc.VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.VPC-gw.id}"
  }

  tags = {
    Name = "VPC-pub"
  }
}

resource "aws_route_table" "VPC-prv" {
  vpc_id = "${aws_vpc.VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.VPC-az1-ng.id}"
  }
 
  tags = {
    Name = "VPC-prv"
  }
}

resource "aws_route_table" "VPC-prv-1" {
  vpc_id = "${aws_vpc.VPC.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.VPC-az2-ng.id}"
  }

  tags = {
    Name = "VPC-prv-1"
  }
}

resource "aws_route_table_association" "art_pub-az1" {
  subnet_id      = "${aws_subnet.VPC-az1-subnets.*.id[1]}"
  route_table_id = "${aws_route_table.VPC-pub.id}"
}

resource "aws_route_table_association" "art_pub-az2" {
  subnet_id      = "${aws_subnet.VPC-az2-subnets.*.id[1]}"
  route_table_id = "${aws_route_table.VPC-pub.id}"
}

resource "aws_route_table_association" "art_prv-az1" {
  subnet_id      = "${aws_subnet.VPC-az1-subnets.*.id[0]}"
  route_table_id = "${aws_route_table.VPC-prv.id}"
}

resource "aws_route_table_association" "art_prv-az2" {
  subnet_id      = "${aws_subnet.VPC-az2-subnets.*.id[0]}"
  route_table_id = "${aws_route_table.VPC-prv-1.id}"
}


