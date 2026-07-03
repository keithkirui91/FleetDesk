        </section>
    </main>
</div>
<div id="toast" class="toast" hidden></div>
<script>window.FLEETDESK_BASE = <?= json_encode(BASE_URL) ?>;</script>
<script src="<?= e(BASE_URL) ?>/app.js?v=<?= e((string)@filemtime(__DIR__ . '/app.js')) ?>"></script>
</body>
</html>
