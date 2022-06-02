// Code generated by protoc-gen-go. DO NOT EDIT.
// versions:
// 	protoc-gen-go v1.25.0
// 	protoc        v3.2.0
// source: source/filters/http/proto/gm-jwt-keycloak.proto

package proto

import (
	proto "github.com/golang/protobuf/proto"
	protoreflect "google.golang.org/protobuf/reflect/protoreflect"
	protoimpl "google.golang.org/protobuf/runtime/protoimpl"
	reflect "reflect"
	sync "sync"
)

const (
	// Verify that this generated code is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(20 - protoimpl.MinVersion)
	// Verify that runtime/protoimpl is sufficiently up-to-date.
	_ = protoimpl.EnforceVersion(protoimpl.MaxVersion - 20)
)

// This is a compile-time assertion that a sufficiently up-to-date version
// of the legacy proto package is being used.
const _ = proto.ProtoPackageIsVersion4

type GmJwtKeycloakConfig struct {
	state         protoimpl.MessageState
	sizeCache     protoimpl.SizeCache
	unknownFields protoimpl.UnknownFields

	ClientSecret    string `protobuf:"bytes,1,opt,name=clientSecret,proto3" json:"clientSecret,omitempty"`
	Endpoint        string `protobuf:"bytes,2,opt,name=endpoint,proto3" json:"endpoint,omitempty"`
	AuthnHeaderName string `protobuf:"bytes,3,opt,name=authnHeaderName,proto3" json:"authnHeaderName,omitempty"`
	// tls
	UseTLS             bool   `protobuf:"varint,4,opt,name=useTLS,proto3" json:"useTLS,omitempty"`
	CertPath           string `protobuf:"bytes,5,opt,name=certPath,proto3" json:"certPath,omitempty"`
	KeyPath            string `protobuf:"bytes,6,opt,name=keyPath,proto3" json:"keyPath,omitempty"`
	CaPath             string `protobuf:"bytes,7,opt,name=caPath,proto3" json:"caPath,omitempty"`
	InsecureSkipVerify bool   `protobuf:"varint,8,opt,name=insecureSkipVerify,proto3" json:"insecureSkipVerify,omitempty"`
	// request config
	TimeoutMs    int32 `protobuf:"varint,9,opt,name=timeoutMs,proto3" json:"timeoutMs,omitempty"`
	MaxRetries   int32 `protobuf:"varint,10,opt,name=maxRetries,proto3" json:"maxRetries,omitempty"`
	RetryDelayMs int32 `protobuf:"varint,11,opt,name=retryDelayMs,proto3" json:"retryDelayMs,omitempty"`
	// cache config
	CachedTokenExp int32 `protobuf:"varint,12,opt,name=cachedTokenExp,proto3" json:"cachedTokenExp,omitempty"`
	CacheLimit     int32 `protobuf:"varint,13,opt,name=cacheLimit,proto3" json:"cacheLimit,omitempty"`
	// keycloak-specifc
	WriteBody               bool   `protobuf:"varint,14,opt,name=writeBody,proto3" json:"writeBody,omitempty"`
	FetchFullToken          bool   `protobuf:"varint,15,opt,name=fetchFullToken,proto3" json:"fetchFullToken,omitempty"`
	ClientID                string `protobuf:"bytes,16,opt,name=clientID,proto3" json:"clientID,omitempty"`
	Realm                   string `protobuf:"bytes,17,opt,name=realm,proto3" json:"realm,omitempty"`
	JwtPrivateKeyPath       string `protobuf:"bytes,18,opt,name=jwtPrivateKeyPath,proto3" json:"jwtPrivateKeyPath,omitempty"`
	AuthzHeaderName         string `protobuf:"bytes,19,opt,name=authzHeaderName,proto3" json:"authzHeaderName,omitempty"`
	Jwks                    string `protobuf:"bytes,20,opt,name=jwks,proto3" json:"jwks,omitempty"`
	AuthenticateOnly        bool   `protobuf:"varint,21,opt,name=authenticateOnly,proto3" json:"authenticateOnly,omitempty"`
	SharedJwtKeycloakSecret string `protobuf:"bytes,22,opt,name=sharedJwtKeycloakSecret,proto3" json:"sharedJwtKeycloakSecret,omitempty"`
}

func (x *GmJwtKeycloakConfig) Reset() {
	*x = GmJwtKeycloakConfig{}
	if protoimpl.UnsafeEnabled {
		mi := &file_source_filters_http_proto_gm_jwt_keycloak_proto_msgTypes[0]
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		ms.StoreMessageInfo(mi)
	}
}

func (x *GmJwtKeycloakConfig) String() string {
	return protoimpl.X.MessageStringOf(x)
}

func (*GmJwtKeycloakConfig) ProtoMessage() {}

func (x *GmJwtKeycloakConfig) ProtoReflect() protoreflect.Message {
	mi := &file_source_filters_http_proto_gm_jwt_keycloak_proto_msgTypes[0]
	if protoimpl.UnsafeEnabled && x != nil {
		ms := protoimpl.X.MessageStateOf(protoimpl.Pointer(x))
		if ms.LoadMessageInfo() == nil {
			ms.StoreMessageInfo(mi)
		}
		return ms
	}
	return mi.MessageOf(x)
}

// Deprecated: Use GmJwtKeycloakConfig.ProtoReflect.Descriptor instead.
func (*GmJwtKeycloakConfig) Descriptor() ([]byte, []int) {
	return file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescGZIP(), []int{0}
}

func (x *GmJwtKeycloakConfig) GetClientSecret() string {
	if x != nil {
		return x.ClientSecret
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetEndpoint() string {
	if x != nil {
		return x.Endpoint
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetAuthnHeaderName() string {
	if x != nil {
		return x.AuthnHeaderName
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetUseTLS() bool {
	if x != nil {
		return x.UseTLS
	}
	return false
}

func (x *GmJwtKeycloakConfig) GetCertPath() string {
	if x != nil {
		return x.CertPath
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetKeyPath() string {
	if x != nil {
		return x.KeyPath
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetCaPath() string {
	if x != nil {
		return x.CaPath
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetInsecureSkipVerify() bool {
	if x != nil {
		return x.InsecureSkipVerify
	}
	return false
}

func (x *GmJwtKeycloakConfig) GetTimeoutMs() int32 {
	if x != nil {
		return x.TimeoutMs
	}
	return 0
}

func (x *GmJwtKeycloakConfig) GetMaxRetries() int32 {
	if x != nil {
		return x.MaxRetries
	}
	return 0
}

func (x *GmJwtKeycloakConfig) GetRetryDelayMs() int32 {
	if x != nil {
		return x.RetryDelayMs
	}
	return 0
}

func (x *GmJwtKeycloakConfig) GetCachedTokenExp() int32 {
	if x != nil {
		return x.CachedTokenExp
	}
	return 0
}

func (x *GmJwtKeycloakConfig) GetCacheLimit() int32 {
	if x != nil {
		return x.CacheLimit
	}
	return 0
}

func (x *GmJwtKeycloakConfig) GetWriteBody() bool {
	if x != nil {
		return x.WriteBody
	}
	return false
}

func (x *GmJwtKeycloakConfig) GetFetchFullToken() bool {
	if x != nil {
		return x.FetchFullToken
	}
	return false
}

func (x *GmJwtKeycloakConfig) GetClientID() string {
	if x != nil {
		return x.ClientID
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetRealm() string {
	if x != nil {
		return x.Realm
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetJwtPrivateKeyPath() string {
	if x != nil {
		return x.JwtPrivateKeyPath
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetAuthzHeaderName() string {
	if x != nil {
		return x.AuthzHeaderName
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetJwks() string {
	if x != nil {
		return x.Jwks
	}
	return ""
}

func (x *GmJwtKeycloakConfig) GetAuthenticateOnly() bool {
	if x != nil {
		return x.AuthenticateOnly
	}
	return false
}

func (x *GmJwtKeycloakConfig) GetSharedJwtKeycloakSecret() string {
	if x != nil {
		return x.SharedJwtKeycloakSecret
	}
	return ""
}

var File_source_filters_http_proto_gm_jwt_keycloak_proto protoreflect.FileDescriptor

var file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDesc = []byte{
	0x0a, 0x2f, 0x73, 0x6f, 0x75, 0x72, 0x63, 0x65, 0x2f, 0x66, 0x69, 0x6c, 0x74, 0x65, 0x72, 0x73,
	0x2f, 0x68, 0x74, 0x74, 0x70, 0x2f, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x2f, 0x67, 0x6d, 0x2d, 0x6a,
	0x77, 0x74, 0x2d, 0x6b, 0x65, 0x79, 0x63, 0x6c, 0x6f, 0x61, 0x6b, 0x2e, 0x70, 0x72, 0x6f, 0x74,
	0x6f, 0x12, 0x2a, 0x67, 0x72, 0x65, 0x79, 0x6d, 0x61, 0x74, 0x74, 0x65, 0x72, 0x5f, 0x69, 0x6f,
	0x2e, 0x67, 0x6d, 0x5f, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x2e, 0x73, 0x6f, 0x75, 0x72, 0x63, 0x65,
	0x2e, 0x66, 0x69, 0x6c, 0x74, 0x65, 0x72, 0x73, 0x2e, 0x68, 0x74, 0x74, 0x70, 0x22, 0x89, 0x06,
	0x0a, 0x13, 0x47, 0x6d, 0x4a, 0x77, 0x74, 0x4b, 0x65, 0x79, 0x63, 0x6c, 0x6f, 0x61, 0x6b, 0x43,
	0x6f, 0x6e, 0x66, 0x69, 0x67, 0x12, 0x22, 0x0a, 0x0c, 0x63, 0x6c, 0x69, 0x65, 0x6e, 0x74, 0x53,
	0x65, 0x63, 0x72, 0x65, 0x74, 0x18, 0x01, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0c, 0x63, 0x6c, 0x69,
	0x65, 0x6e, 0x74, 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x12, 0x1a, 0x0a, 0x08, 0x65, 0x6e, 0x64,
	0x70, 0x6f, 0x69, 0x6e, 0x74, 0x18, 0x02, 0x20, 0x01, 0x28, 0x09, 0x52, 0x08, 0x65, 0x6e, 0x64,
	0x70, 0x6f, 0x69, 0x6e, 0x74, 0x12, 0x28, 0x0a, 0x0f, 0x61, 0x75, 0x74, 0x68, 0x6e, 0x48, 0x65,
	0x61, 0x64, 0x65, 0x72, 0x4e, 0x61, 0x6d, 0x65, 0x18, 0x03, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0f,
	0x61, 0x75, 0x74, 0x68, 0x6e, 0x48, 0x65, 0x61, 0x64, 0x65, 0x72, 0x4e, 0x61, 0x6d, 0x65, 0x12,
	0x16, 0x0a, 0x06, 0x75, 0x73, 0x65, 0x54, 0x4c, 0x53, 0x18, 0x04, 0x20, 0x01, 0x28, 0x08, 0x52,
	0x06, 0x75, 0x73, 0x65, 0x54, 0x4c, 0x53, 0x12, 0x1a, 0x0a, 0x08, 0x63, 0x65, 0x72, 0x74, 0x50,
	0x61, 0x74, 0x68, 0x18, 0x05, 0x20, 0x01, 0x28, 0x09, 0x52, 0x08, 0x63, 0x65, 0x72, 0x74, 0x50,
	0x61, 0x74, 0x68, 0x12, 0x18, 0x0a, 0x07, 0x6b, 0x65, 0x79, 0x50, 0x61, 0x74, 0x68, 0x18, 0x06,
	0x20, 0x01, 0x28, 0x09, 0x52, 0x07, 0x6b, 0x65, 0x79, 0x50, 0x61, 0x74, 0x68, 0x12, 0x16, 0x0a,
	0x06, 0x63, 0x61, 0x50, 0x61, 0x74, 0x68, 0x18, 0x07, 0x20, 0x01, 0x28, 0x09, 0x52, 0x06, 0x63,
	0x61, 0x50, 0x61, 0x74, 0x68, 0x12, 0x2e, 0x0a, 0x12, 0x69, 0x6e, 0x73, 0x65, 0x63, 0x75, 0x72,
	0x65, 0x53, 0x6b, 0x69, 0x70, 0x56, 0x65, 0x72, 0x69, 0x66, 0x79, 0x18, 0x08, 0x20, 0x01, 0x28,
	0x08, 0x52, 0x12, 0x69, 0x6e, 0x73, 0x65, 0x63, 0x75, 0x72, 0x65, 0x53, 0x6b, 0x69, 0x70, 0x56,
	0x65, 0x72, 0x69, 0x66, 0x79, 0x12, 0x1c, 0x0a, 0x09, 0x74, 0x69, 0x6d, 0x65, 0x6f, 0x75, 0x74,
	0x4d, 0x73, 0x18, 0x09, 0x20, 0x01, 0x28, 0x05, 0x52, 0x09, 0x74, 0x69, 0x6d, 0x65, 0x6f, 0x75,
	0x74, 0x4d, 0x73, 0x12, 0x1e, 0x0a, 0x0a, 0x6d, 0x61, 0x78, 0x52, 0x65, 0x74, 0x72, 0x69, 0x65,
	0x73, 0x18, 0x0a, 0x20, 0x01, 0x28, 0x05, 0x52, 0x0a, 0x6d, 0x61, 0x78, 0x52, 0x65, 0x74, 0x72,
	0x69, 0x65, 0x73, 0x12, 0x22, 0x0a, 0x0c, 0x72, 0x65, 0x74, 0x72, 0x79, 0x44, 0x65, 0x6c, 0x61,
	0x79, 0x4d, 0x73, 0x18, 0x0b, 0x20, 0x01, 0x28, 0x05, 0x52, 0x0c, 0x72, 0x65, 0x74, 0x72, 0x79,
	0x44, 0x65, 0x6c, 0x61, 0x79, 0x4d, 0x73, 0x12, 0x26, 0x0a, 0x0e, 0x63, 0x61, 0x63, 0x68, 0x65,
	0x64, 0x54, 0x6f, 0x6b, 0x65, 0x6e, 0x45, 0x78, 0x70, 0x18, 0x0c, 0x20, 0x01, 0x28, 0x05, 0x52,
	0x0e, 0x63, 0x61, 0x63, 0x68, 0x65, 0x64, 0x54, 0x6f, 0x6b, 0x65, 0x6e, 0x45, 0x78, 0x70, 0x12,
	0x1e, 0x0a, 0x0a, 0x63, 0x61, 0x63, 0x68, 0x65, 0x4c, 0x69, 0x6d, 0x69, 0x74, 0x18, 0x0d, 0x20,
	0x01, 0x28, 0x05, 0x52, 0x0a, 0x63, 0x61, 0x63, 0x68, 0x65, 0x4c, 0x69, 0x6d, 0x69, 0x74, 0x12,
	0x1c, 0x0a, 0x09, 0x77, 0x72, 0x69, 0x74, 0x65, 0x42, 0x6f, 0x64, 0x79, 0x18, 0x0e, 0x20, 0x01,
	0x28, 0x08, 0x52, 0x09, 0x77, 0x72, 0x69, 0x74, 0x65, 0x42, 0x6f, 0x64, 0x79, 0x12, 0x26, 0x0a,
	0x0e, 0x66, 0x65, 0x74, 0x63, 0x68, 0x46, 0x75, 0x6c, 0x6c, 0x54, 0x6f, 0x6b, 0x65, 0x6e, 0x18,
	0x0f, 0x20, 0x01, 0x28, 0x08, 0x52, 0x0e, 0x66, 0x65, 0x74, 0x63, 0x68, 0x46, 0x75, 0x6c, 0x6c,
	0x54, 0x6f, 0x6b, 0x65, 0x6e, 0x12, 0x1a, 0x0a, 0x08, 0x63, 0x6c, 0x69, 0x65, 0x6e, 0x74, 0x49,
	0x44, 0x18, 0x10, 0x20, 0x01, 0x28, 0x09, 0x52, 0x08, 0x63, 0x6c, 0x69, 0x65, 0x6e, 0x74, 0x49,
	0x44, 0x12, 0x14, 0x0a, 0x05, 0x72, 0x65, 0x61, 0x6c, 0x6d, 0x18, 0x11, 0x20, 0x01, 0x28, 0x09,
	0x52, 0x05, 0x72, 0x65, 0x61, 0x6c, 0x6d, 0x12, 0x2c, 0x0a, 0x11, 0x6a, 0x77, 0x74, 0x50, 0x72,
	0x69, 0x76, 0x61, 0x74, 0x65, 0x4b, 0x65, 0x79, 0x50, 0x61, 0x74, 0x68, 0x18, 0x12, 0x20, 0x01,
	0x28, 0x09, 0x52, 0x11, 0x6a, 0x77, 0x74, 0x50, 0x72, 0x69, 0x76, 0x61, 0x74, 0x65, 0x4b, 0x65,
	0x79, 0x50, 0x61, 0x74, 0x68, 0x12, 0x28, 0x0a, 0x0f, 0x61, 0x75, 0x74, 0x68, 0x7a, 0x48, 0x65,
	0x61, 0x64, 0x65, 0x72, 0x4e, 0x61, 0x6d, 0x65, 0x18, 0x13, 0x20, 0x01, 0x28, 0x09, 0x52, 0x0f,
	0x61, 0x75, 0x74, 0x68, 0x7a, 0x48, 0x65, 0x61, 0x64, 0x65, 0x72, 0x4e, 0x61, 0x6d, 0x65, 0x12,
	0x12, 0x0a, 0x04, 0x6a, 0x77, 0x6b, 0x73, 0x18, 0x14, 0x20, 0x01, 0x28, 0x09, 0x52, 0x04, 0x6a,
	0x77, 0x6b, 0x73, 0x12, 0x2a, 0x0a, 0x10, 0x61, 0x75, 0x74, 0x68, 0x65, 0x6e, 0x74, 0x69, 0x63,
	0x61, 0x74, 0x65, 0x4f, 0x6e, 0x6c, 0x79, 0x18, 0x15, 0x20, 0x01, 0x28, 0x08, 0x52, 0x10, 0x61,
	0x75, 0x74, 0x68, 0x65, 0x6e, 0x74, 0x69, 0x63, 0x61, 0x74, 0x65, 0x4f, 0x6e, 0x6c, 0x79, 0x12,
	0x38, 0x0a, 0x17, 0x73, 0x68, 0x61, 0x72, 0x65, 0x64, 0x4a, 0x77, 0x74, 0x4b, 0x65, 0x79, 0x63,
	0x6c, 0x6f, 0x61, 0x6b, 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x18, 0x16, 0x20, 0x01, 0x28, 0x09,
	0x52, 0x17, 0x73, 0x68, 0x61, 0x72, 0x65, 0x64, 0x4a, 0x77, 0x74, 0x4b, 0x65, 0x79, 0x63, 0x6c,
	0x6f, 0x61, 0x6b, 0x53, 0x65, 0x63, 0x72, 0x65, 0x74, 0x42, 0x3d, 0x5a, 0x3b, 0x67, 0x69, 0x74,
	0x68, 0x75, 0x62, 0x2e, 0x63, 0x6f, 0x6d, 0x2f, 0x67, 0x72, 0x65, 0x79, 0x6d, 0x61, 0x74, 0x74,
	0x65, 0x72, 0x2d, 0x69, 0x6f, 0x2f, 0x67, 0x6d, 0x2d, 0x70, 0x72, 0x6f, 0x78, 0x79, 0x2f, 0x73,
	0x6f, 0x75, 0x72, 0x63, 0x65, 0x2f, 0x66, 0x69, 0x6c, 0x74, 0x65, 0x72, 0x73, 0x2f, 0x68, 0x74,
	0x74, 0x70, 0x2f, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x62, 0x06, 0x70, 0x72, 0x6f, 0x74, 0x6f, 0x33,
}

var (
	file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescOnce sync.Once
	file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescData = file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDesc
)

func file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescGZIP() []byte {
	file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescOnce.Do(func() {
		file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescData = protoimpl.X.CompressGZIP(file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescData)
	})
	return file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDescData
}

var file_source_filters_http_proto_gm_jwt_keycloak_proto_msgTypes = make([]protoimpl.MessageInfo, 1)
var file_source_filters_http_proto_gm_jwt_keycloak_proto_goTypes = []interface{}{
	(*GmJwtKeycloakConfig)(nil), // 0: greymatter_io.gm_proxy.source.filters.http.GmJwtKeycloakConfig
}
var file_source_filters_http_proto_gm_jwt_keycloak_proto_depIdxs = []int32{
	0, // [0:0] is the sub-list for method output_type
	0, // [0:0] is the sub-list for method input_type
	0, // [0:0] is the sub-list for extension type_name
	0, // [0:0] is the sub-list for extension extendee
	0, // [0:0] is the sub-list for field type_name
}

func init() { file_source_filters_http_proto_gm_jwt_keycloak_proto_init() }
func file_source_filters_http_proto_gm_jwt_keycloak_proto_init() {
	if File_source_filters_http_proto_gm_jwt_keycloak_proto != nil {
		return
	}
	if !protoimpl.UnsafeEnabled {
		file_source_filters_http_proto_gm_jwt_keycloak_proto_msgTypes[0].Exporter = func(v interface{}, i int) interface{} {
			switch v := v.(*GmJwtKeycloakConfig); i {
			case 0:
				return &v.state
			case 1:
				return &v.sizeCache
			case 2:
				return &v.unknownFields
			default:
				return nil
			}
		}
	}
	type x struct{}
	out := protoimpl.TypeBuilder{
		File: protoimpl.DescBuilder{
			GoPackagePath: reflect.TypeOf(x{}).PkgPath(),
			RawDescriptor: file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDesc,
			NumEnums:      0,
			NumMessages:   1,
			NumExtensions: 0,
			NumServices:   0,
		},
		GoTypes:           file_source_filters_http_proto_gm_jwt_keycloak_proto_goTypes,
		DependencyIndexes: file_source_filters_http_proto_gm_jwt_keycloak_proto_depIdxs,
		MessageInfos:      file_source_filters_http_proto_gm_jwt_keycloak_proto_msgTypes,
	}.Build()
	File_source_filters_http_proto_gm_jwt_keycloak_proto = out.File
	file_source_filters_http_proto_gm_jwt_keycloak_proto_rawDesc = nil
	file_source_filters_http_proto_gm_jwt_keycloak_proto_goTypes = nil
	file_source_filters_http_proto_gm_jwt_keycloak_proto_depIdxs = nil
}
