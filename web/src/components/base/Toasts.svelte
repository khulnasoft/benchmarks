<script>
    import { fade } from "svelte/transition";
    import { flip } from "svelte/animate";
    import { toasts, removeToast } from "@/stores/toasts";
</script>

<div class="toasts-wrapper">
    {#each $toasts as toast (toast.message)}
        <div
            class="alert txt-break"
            class:alert-info={toast.type == "info"}
            class:alert-success={toast.type == "success"}
            class:alert-danger={toast.type == "error"}
            class:alert-warning={toast.type == "warning"}
            transition:fade={{ duration: 150 }}
            animate:flip={{ duration: 150 }}
        >
            <div class="icon">
                {#if toast.type === "info"}
                    <i class="ri-information-line" />
                {:else if toast.type === "success"}
                    <i class="ri-checkbox-circle-line" />
                {:else}
                    <i class="ri-alert-line" />
                {/if}
            </div>

            <div class="content">{toast.message}</div>

            <div class="close" on:click|preventDefault={() => removeToast(toast)}>
                <i class="ri-close-line" />
            </div>
        </div>
    {/each}
</div>
