ARGOCD_CHART_VERSION ?= 7.7.5  

.PHONY: cluster-up cluster-down argocd-install argocd-root \
        argocd-port-forward  help

help:
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*##/ { printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

cluster-up: 
	eksctl create cluster -f cluster/eksctl.yaml
	$(MAKE) argocd-install
	$(MAKE) argocd-root
	@echo
	@echo "Cluster up. Next:"
	@echo "  make argocd-port-forward    # in one terminal"

cluster-down: 
	eksctl delete cluster -f cluster/eksctl.yaml

argocd-install:
	kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
	helm repo add argo https://argoproj.github.io/argo-helm
	helm repo update
	helm upgrade --install argocd argo/argo-cd \
		--namespace argocd \
		--version $(ARGOCD_CHART_VERSION) \
		--wait

argocd-root:
	kubectl apply -f argocd/root-app.yaml

argocd-port-forward:
	kubectl port-forward -n argocd svc/argocd-server 8080:443
