package pipelines

import (
	"net/http"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase/core"
	"github.com/khulnasoft/kubench/internal/execution"
	"github.com/khulnasoft/kubench/internal/run"
	"github.com/khulnasoft/kubench/middlewares"
)

func InitRoutes(app *execution.App) {
	healthcheck(app)

	runs(app)
}

func healthcheck(app *execution.App) {
	app.PB.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.AddRoute(echo.Route{
			Method: http.MethodGet,
			Path:   "/api/health",
			Handler: func(c echo.Context) error {
				return c.String(200, "ok")
			},
			Middlewares: []echo.MiddlewareFunc{},
		})
		return nil
	})

	app.PB.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.AddRoute(echo.Route{
			Method: http.MethodHead,
			Path:   "/api/health",
			Handler: func(c echo.Context) error {
				return c.String(200, "ok")
			},
			Middlewares: []echo.MiddlewareFunc{},
		})
		return nil
	})
}

func runs(app *execution.App) {
	app.PB.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		e.Router.AddRoute(echo.Route{
			Method:  http.MethodPost,
			Path:    "/api/runs",
			Handler: run.NewHandler(app),
			Middlewares: []echo.MiddlewareFunc{
				middlewares.RequireAdminOrPrivilegedAuth(),
			},
		})
		return nil
	})
}
