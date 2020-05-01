# Build the manager binary
FROM golang:1.13 as builder

# Copy everything in the go src
WORKDIR /go/src/cdap.io/cdap-operator
# Copy the Go Modules manifests
COPY go.mod go.mod
COPY go.sum go.sum
COPY vendor/ vendor/

# cache deps before building and copying source so that we don't need to re-download as much
# and so that source changes don't invalidate our downloaded layer
RUN go mod download

# Copy the go source
COPY main.go main.go
COPY api/ api/
COPY controllers/ controllers/

# Build
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 GO111MODULE=on go build -a -o manager ./main.go

# Copy the controller-manager into a thin image
FROM ubuntu:latest
WORKDIR /
COPY --from=builder /go/src/cdap.io/cdap-operator/manager .
COPY templates/ templates/
COPY config/ config/
ENTRYPOINT ["/manager"]
