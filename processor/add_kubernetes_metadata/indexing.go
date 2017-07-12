package add_kubernetes_metadata

import (
	"github.com/elastic/beats/libbeat/common"
	"github.com/elastic/beats/libbeat/logp"
	"github.com/elastic/beats/libbeat/processors/add_kubernetes_metadata"
)

func init() {
	add_kubernetes_metadata.Indexing.AddMatcher(ContainerIdMatcherName, newMatcher)
	cfg := common.NewConfig()

	add_kubernetes_metadata.Indexing.AddDefaultIndexerConfig(add_kubernetes_metadata.ContainerIndexerName, *cfg)
	add_kubernetes_metadata.Indexing.AddDefaultMatcherConfig(ContainerIdMatcherName, *cfg)
}

const ContainerIdMatcherName = "container_id_full"

type ContainerIdMatcher struct {
}

func newMatcher(cfg common.Config) (add_kubernetes_metadata.Matcher, error) {
	return &ContainerIdMatcher{}, nil
}

func (f *ContainerIdMatcher) MetadataIndex(event common.MapStr) string {
	if journal, ok := event["journal"]; ok {
		if value, ok := journal.(common.MapStr)["container_id_full"]; ok {
			cid := value.(string)
			logp.Debug("kubernetes", "Using container id: ", cid)
			if cid != "" {
				return cid
			}
		}
	}
	return ""
}
