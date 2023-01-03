package greymatter


// In the tls spec block you can set up the following configurations:
//     plaintext edge + plaintext internal (default behavior)
//     plaintext edge + spire internal
//     tls edge + manual-certs internal
//     tls edge + spire internal
#SecuritySpecv1:{
    edge:{
        type: "plaintext" | "tls"
        secret_name: string
    }

    internal:{
        type: [
            if (edge.type == "tls"){ "plaintext" | "spire" | "manual-certs"}
            if (edge.type =="plaintext") { "plaintext" | "spire"}
        ][0]
        spire:{
            namespace: string
            trust_domain: string
            socket_mount_path: string
            ca_secret_name: string
            host_mount_socket: bool
        }
        manual?: {
            secret_name: string
        }
    }
}

// This is a translation layer from what we have in inputs.cue
// The _tls_config unified with the spec allows us to ensure use of working schemas and provide fall back options
// Currently security configs throughout the cue refer to this block
_security_spec: #SecuritySpecv1 &{
    edge:{
        type: [
            if defaults.edge.enable_tls == true {"tls"}
            if defaults.edge.enable_tls == false {"plaintext"}
        ][0]
        secret_name: defaults.edge.secret_name
    }
    internal:{
        type: [
            if config.spire == true {"spire"}
            if defaults.core_internal_tls_certs.enable == true {"manual-certs"}
            "plaintext"
        ][0]
        spire: defaults.spire
        manual:{
            secret_name: defaults.core_internal_tls_certs.cert_secret
        } 
    }
}