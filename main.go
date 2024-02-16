package main

import (
	"context"

	"github.com/hashicorp/go-version"
	"github.com/hashicorp/hc-install/product"
	"github.com/hashicorp/hc-install/releases"
	"github.com/rs/zerolog"
	"github.com/rs/zerolog/log"
	"github.com/spf13/viper"

	"github.com/pocketbase/pocketbase"
	"github.com/khulnasoft/kubench/internal/execution"
	"github.com/khulnasoft/kubench/internal/terraform"
	_ "github.com/khulnasoft/kubench/migrations"
	"github.com/khulnasoft/kubench/pipelines"
)

func main() {
	viper.SetEnvPrefix("KUBENCH")
	viper.AutomaticEnv()

	log.Logger = log.Level(zerolog.InfoLevel)

	installer := &releases.ExactVersion{
		Product: product.Terraform,
		Version: version.Must(version.NewVersion("1.2.6")),
	}

	execPath, err := installer.Install(context.Background())
	if err != nil {
		log.Fatal().Err(err).Msg("error installing Terraform")
	}

	tf := terraform.New(execPath)
	pb := pocketbase.New()
	app := execution.New(pb, tf)

	pipelines.InitRoutes(app)
	pipelines.InitUI(app)
	pipelines.InitUser(app)

	go func() {
		if err := app.NewCron(); err != nil {
			log.Fatal().Err(err).Msg("error starting cron")
		}
	}()

	if err := pb.Start(); err != nil {
		log.Fatal().Err(err)
	}
}
