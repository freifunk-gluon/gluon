function update_node(id, ip, hostname) {
  var el = document.getElementById(id);

  if (!el)
    return;

  el.href = "http://[" + ip + "]/";
  el.textContent += " (" + hostname + ")";
}
