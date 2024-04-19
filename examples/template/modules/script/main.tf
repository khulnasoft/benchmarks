# creating ec2 instance that will be used to generate load
# Most likely you will not need to change it
resource "aws_instance" "k6" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  subnet_id              = var.subnet_id

  key_name = var.key_name

  tags = {
    terraform   = "true"
    environment = "qa"
    app         = var.sut_name
    creator     = "kenbench"
  }
}

# uploading k6 scripts and running k6 load test
resource "null_resource" "remote" {
  # ssh into instance, you likely won't need to change this part
  connection {
    type        = "ssh"
    user        = var.instance_user
    host        = aws_instance.k6.public_ip
    private_key = var.private_key_location
    timeout     = "1m"
  }

  # upload k6 scripts to remote instance, you likely won't need to change this part
  provisioner "file" {
    source      = "${path.root}/k6"
    destination = "/tmp"
  }

  # upload entrypoint script to remote instance
  # specify your custom variables here
  provisioner "file" {
    destination = "/tmp/k6/entrypoint.sh"
    
    content = templatefile(
      "${path.module}/entrypoint.sh.tpl",
      {
        # add your custom variables here
        some_var        = var.some_var
        sut_token       = var.sut_token
        sut_url         = var.sut_url

        duration        = var.duration

        # don't change these
        testrun_id      = var.testrun_id
        benchmark_id    = var.benchmark_id
        testrun_name    = var.testrun_name
        test_origin     = var.test_origin
        kenbench_token = var.kenbench_token
        kenbench_uri   = var.kenbench_uri
      }
    )
  }

  # set env vars
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      # add your env vars here:
      "echo \"export SOME_VAR='${var.some_var}'\" >> ~/.bashrc",
      "echo \"export SUT_TOKEN='${var.sut_token}'\" >> ~/.bashrc",
      "echo \"export SUT_URL='${var.sut_url}'\" >> ~/.bashrc",
      # don't change these:
      "echo \"export RUN_ID='${var.testrun_id}'\" >> ~/.bashrc",
      "echo \"export BENCHMARK_ID='${var.benchmark_id}'\" >> ~/.bashrc",
      "echo \"export TEST_RUN='${var.testrun_name}'\" >> ~/.bashrc",
      "echo \"export TEST_ORIGIN='${var.test_origin}'\" >> ~/.bashrc",
      "echo \"export KENBENCH_TOKEN='${var.kenbench_token}'\" >> ~/.bashrc",
      "echo \"export KENBENCH_URI='${var.kenbench_uri}'\" >> ~/.bashrc",
    ]
  }

  # run k6 load test, you likely won't need to change this part
  provisioner "remote-exec" {
    inline = [
      "#!/bin/bash",
      "source ~/.bashrc",
      "sudo chown -R ubuntu:ubuntu /tmp/k6",
      "sudo chmod +x /tmp/k6/entrypoint.sh",
      "/tmp/k6/entrypoint.sh",
    ]
  }

  # we should provide instance first so that we can ssh into it
  depends_on = [
    aws_instance.k6,
  ]
}